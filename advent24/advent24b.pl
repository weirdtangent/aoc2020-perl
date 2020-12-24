#!/usr/bin/perl -wT

$| = 1;

my $verbose = 0;

my $tiles;

my $tilenum = 0;

use constant BLACK => 1;
use constant WHITE => -1;

our $floor = {};

while(my $line = <STDIN>) {
  chomp $line;
  @{$tiles->{$tilenum++}} = $line =~ /[ns]?[ew]/g;
}

# set tiles
foreach $tile (keys %$tiles) {
  my ($ns, $ew) = (0,0);
  for my $dir (@{$tiles->{$tile}}) {
    if ($dir =~ /^[ns]/ ) {
      $ns += $dir =~ /^n/ ? 1 : -1;
      $ew += $dir =~ /e$/ ? 1 : -1;
    }
    else {
      $ew += $dir =~ /e$/ ? 2 : -2;
    }
  }
  my $loc = "$ew,$ns";
  $floor->{$loc} = WHITE if !exists $floor->{$loc}; # tiles start as white
  $floor->{$loc} *= -1; # flip tile
}

my $counts = count_tiles();
print $counts->{white}." white tiles and ".$counts->{black}." black tiles\n";

# flip each day
my ($range_x, $range_y) = (30,30);
for my $day (1..100) {
  my @flip;
  for my $x (-$range_x..$range_x) {
    for my $y (-$range_y..$range_y) {
      my $pos = "$x,$y";
      $floor->{$pos} //= WHITE;
      my $black_adjacent = adjacent_black($pos);
      push @flip, $pos
        if ($floor->{$pos} == BLACK && ($black_adjacent == 0 || $black_adjacent > 2))
        || ($floor->{$pos} == WHITE && ($black_adjacent == 2));
    }
  }
  $range_x++;
  $range_y++;

  $floor->{$_} *= -1 foreach (@flip);

  print "Day $day: ".(count_tiles())->{black}."\n";
}

# check tiles:
$counts = count_tiles();
print $counts->{white}." white tiles and ".$counts->{black}." black tiles\n";


sub count_tiles {
  my $white = 0;
  my $black = 0;

  foreach my $pos (keys %$floor) {
    $black++ if $floor->{$pos} == BLACK;
    $white++ if $floor->{$pos} == WHITE;
  }
  return { white => $white, black => $black };
}


sub adjacent_black {
  my ($pos) = @_;

  my $count = 0;
  my ($x, $y) = split ',', $pos;
  my @check = ( '-1,1', '1,1', '-2,0', '2,0', '-1,-1', '1,-1' );

  for my $alter (@check) {
    my ($dx, $dy) = split ',', $alter;
    my $checkpos = ($x+$dx).','.($y+$dy);
    $floor->{$checkpos} = WHITE if !exists $floor->{$checkpos}; # start tile as white if adjacent tile didn't "exist" yet
    $count++ if $floor->{$checkpos} == BLACK;
  }
  return $count;
}
