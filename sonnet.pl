#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;

sub create_ngrams {
  my %ngrams;
  open TAX, "tax_common.txt" or die "can't";
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

#my $match_string = "iloveyouwiththewhitehotintensityofathousandsuns";
my $match_string = "ilywtwhioats";


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

use Time::HiRes qw(time);
my $start = time();
add_children($tree, "i");
my $end = time();
printf("%.4f\n", $end - $start);
$start = time();
add_children($tree, "il");
$end = time();
printf("%.4f\n", $end - $start);
$start = time();
add_children($tree, "ily");
$end = time();
printf("%.4f\n", $end - $start);
$start = time();
add_children($tree, "ilyw");
$end = time();
printf("%.4f\n", $end - $start);
$start = time();
add_children($tree, "ilywt");
$end = time();
printf("%.4f\n", $end - $start);
$start = time();
add_children($tree, "ilywtw");
$end = time();
printf("%.4f\n", $end - $start);
$start = time();
add_children($tree, "ilywtwh");
$end = time();
printf("%.4f\n", $end - $start);
$start = time();
add_children($tree, "ilywtwhi");
$end = time();
printf("%.4f\n", $end - $start);
$start = time();
add_children($tree, "ilywtwhio");
$end = time();
printf("%.4f\n", $end - $start);
$start = time();
add_children($tree, "ilywtwhioa");
$end = time();
printf("%.4f\n", $end - $start);
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
