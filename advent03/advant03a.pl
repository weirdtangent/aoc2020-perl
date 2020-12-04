#!/usr/bin/perl -Tw

my @map;

while (<STDIN>) {
  chomp;
  push @map, $_;
}

my ($x, $y) = (0, 0);
my ($right, $down) = (3, 1);
my $trees = 0;
my $width = length($map[0]);

do {
  $trees+=1 if (split '', $map[$y])[$x] eq '#';
  $x += $right;
  $y += $down;
  $x -= $width if $x >= $width;
}
while ($y < @map);

print "$trees trees at right $right, down $down\n";
