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
