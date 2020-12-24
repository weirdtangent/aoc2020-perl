#!/usr/bin/perl -wT

my $verbose = 0;

my $tiles;
my $white = 0;
my $black = 0;

my $tilenum = 0;

my $floor = {};

while(my $line = <STDIN>) {
  chomp $line;
  @{$tiles->{$tilenum++}} = $line =~ /[ns]?[ew]/g;
}

foreach $tile (keys %$tiles) {
  my ($ns, $ew) = (0,0);
  for my $dir (@{$tiles->{$tile}}) {
    if ($dir =~ /^[ns]/ ) {
      $ns += $dir =~ /^n/ ? 0.5 : -0.5;
      $ew += $dir =~ /e$/ ? 0.5 : -0.5;
    }
    else {
      $ew += $dir =~ /e$/ ? 1 : -1;
    }
  }
  my $loc = "$ew,$ns";
  print "Flipping tile $loc\n";
  ($floor->{$loc}//0) == 0 ? $floor->{$loc} = -1 : $floor->{$loc} *= -1;
}

foreach my $pos (keys %$floor) {
  $floor->{$pos} == 1 ? $black++ : $white++;
}
print "$white white tiles and $black black tiles\n";
