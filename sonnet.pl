#!/usr/bin/perl

# USAGE: sonnet.pl taxonomy_file_name  match_string

use warnings;
use strict;
use Data::Dumper;

my $taxonomy_file_name = $ARGV[0];
-e $taxonomy_file_name or die "can't open taxonomy file: $!";
my $match_string = $ARGV[1];
$match_string or die "match string not supplied";
$match_string =~ /^\w+$/ or die "non-word characters";
$match_string = lc($match_string);

sub create_ngrams {
  my %ngrams;
  open TAX, $taxonomy_file_name or die "can't";
  while (my $species = <TAX>) {
    chomp $species;
    my @words = split /[\. -]/, $species;
    #print @words, "\n";
    my @letters = map {s/(.).*/$1/; $_} @words;
    my $letters = join "", @letters;
    $letters = lc($letters);
    #print "$letters\n";
    push @{$ngrams{$letters}}, $species;
  }
  return(%ngrams)
}

our %ngrams = create_ngrams();
#print Dumper %ngrams;

# Now that I've had a chance to sleep on it, let's rethink this.
# I want to come up with all of the possible sets of bird name acrostics for a
# given string.

# The maximum number of letters is six. Given a string, I need to try leading
# substrings of from 1-6 characters. For each of these which returns a match,
# I need to save all of the matching birds, and run the remainder of the string
# through this procedure.

# Since I am going to add birds for the letters q, u, and x, I can assume that 
# at least the single-letter string will always match.

# So what does my data structure look like? It's basically a tree. From the 
# head of the string "ilywtwhioats" I have
#	 
# head > Iris Lorikeet > Yellow-winged Tanager > Whistling Heron
#						 White Hawk
#						 ...
#			 Yucatan Woodpecker
#			 Yellow Wattlebird
#			 ...
#			 Yellowbill
#			 Yellowhammer
#			 ...
#	 Ibisbill
#	 Iiwi

# I can use Tree::Simple to construct such a tree. Then all I have to do is 
# traverse it recursively, and collect the leaf nodes. Then grab their parents
# to construct their sequence.
use Tree::Simple;
use Data::TreeDumper;

my $tree = Tree::Simple->new("0", Tree::Simple->ROOT);

sub check_string {
  my ($string, $n) = @_;
  if ($n > length($string)) {
    return ();
  }
  if ($ngrams{substr($string, 0, $n)}) {
    return @{$ngrams{substr($string, 0, $n)}};
  } else {
    return ();
  }

}

sub add_children {
  my($tree, $string) = @_;
  foreach my $n (1..6) {
    my @hits = check_string($string, $n);
    foreach my $hit (@hits) {
      my $subtree = Tree::Simple->new($hit, $tree);
      add_children($subtree, substr($string, $n));
    }
  }
}


# OK, that worked logically and correctly, and it was very beautiful to see the
# trees for shorter strings! However, it appears to be, like, O(e^n). Not very
# robust! It runs out of RAM on my 16GB machine at "ilywtwhioa".

# Let's try it depth-first. The check_string will come in handy...

sub depth_first {
  my ($match_string, @previous) = @_;
  if ($match_string eq "") {
    print join ", ", @previous;
    print "\n";
    return;
  }
  foreach my $n (reverse 1..6) {
    my @res = check_string($match_string, $n);
    if (@res) {
      #print "@res\n";
      foreach my $res (@res) {
	my @so_far = @previous;
	push @so_far, $res;
        depth_first(substr($match_string, $n), @so_far);
      }
    }
  }
}

depth_first($match_string, ());


#$start = time();
#add_children($tree, "ilywtwhioa");
#$end = time();
#printf("%.4f\n", $end - $start);
#print DumpTree($tree);
#print Tree::Simple::getChildCount($tree);
  #$tree->traverse(sub { my ($_tree) = @_; print (("\t" x $_tree->getDepth()), $_tree->getNodeValue(), "\n"); });


## run at command-line with a single query of letters, e.g. "tst" to return
## Three-streaked Tchagra
#my $query = $ARGV[0];
#if ($ngrams{$query}) {
#  print join "\n", @{$ngrams{$query}};
#  print "\n";
#}
