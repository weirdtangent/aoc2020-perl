#!/usr/bin/perl -Tw

my $correct=0;

while (<STDIN>) {
  if (my ($first, $second, $letter, $pwd) = $_ =~ /^(\d+)\-(\d+) (\w): (\w+)/) {
    my @letters = split '', $pwd;
    $correct+=1 if $letters[$first-1] eq $letter xor $letters[$second-1] eq $letter; 
  }
}

print "$correct correct passwords\n";

