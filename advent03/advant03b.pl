#!/usr/bin/perl -Tw

my @map;

while (<STDIN>) {
  chomp;
  push @map, $_;
}

my $mult = 1;

$mult *= findtrees(1,1,\@map);
$mult *= findtrees(3,1,\@map);
$mult *= findtrees(5,1,\@map);
$mult *= findtrees(7,1,\@map);
$mult *= findtrees(1,2,\@map);

print "\n$mult is that multiplied out\n";

sub findtrees {
  my ($right, $down, $map) = @_;
  my ($x, $y) = (0, 0);
  my $trees = 0;
  my $width = length($map[0]);

  do {
    $trees+=1 if (split '', $map->[$y])[$x] eq '#';
    $x += $right;
    $y += $down;
    $x -= $width if $x >= $width;
  }
  while ($y < @map);
  print "$trees trees at right $right, down $down\n";
  return $trees;
}

