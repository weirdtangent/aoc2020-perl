#!/usr/bin/perl -Tw

my $correct=0;

while (<STDIN>) {
  if (my ($min, $max, $letter, $pwd) = $_ =~ /^(\d+)\-(\d+) (\w): (\w+)/) {
    my $count = grep /$letter/, split '', $pwd;
    $correct+=1 if $count >= $min && $count <= $max;
  }
}

print "$correct correct passwords\n";

