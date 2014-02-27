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

