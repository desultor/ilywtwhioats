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
print Dumper %ngrams;

#my $match_string = "iloveyouwiththewhitehotintensityofathousandsuns";
my $match_string = "ilywtwhioats";

# i gotta query the parts of this match string
# how about just randomly?
#
# or create a funky state machine?

# start with one-by-one?

# randomly try one, two, or three characters. If three works, go with it and
# choose one of the results at random, passing the remnant of the string back
# in. If three doesn't work, fail down to two. If that doesn't work, fail down
# to one.

sub carmondize {
  my $match_string = shift;
  my $increment = int(rand(3)) + 1;
  sub try_phrase {
    my ($match_string, $increment, %ngrams) = @_;
    if ($ngrams{substr($match_string, 0, $increment)}) {
      my @candidates = @{$ngrams{substr($match_string, 0, $increment)}};
      return $candidates[int rand scalar @candidates];
    } else {
      return(-1);
    }
  }

  # if match string is as long as or longer than increment
  #   try the "increment" section of the match string
  #   if that worked
  #     choose a random value
  #     carmondize the remainder
  #   if it didn't work
  #     if increment is greater than one
  #       subtract one from increment
  #         try again
  #     if increment is not greater than one
  #       die




  #print $increment;
}

#carmondize("foo");


## run at command-line with a single query of letters, e.g. "tst" to return
## Three-streaked Tchagra
#my $query = $ARGV[0];
#if ($ngrams{$query}) {
#  print join "\n", @{$ngrams{$query}};
#  print "\n";
#}
