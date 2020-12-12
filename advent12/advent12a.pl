#!/usr/bin/perl -Tw

my $facing = 3;
my $compass = [ 'N', 'W', 'S', 'E' ];
my $ns_pos = 0;
my $ew_pos = 0;

while (my $line = <STDIN>) {
  chomp $line;
  my ($command, $distance) = $line =~ /^(\w)(\d+)/;
  print "Ship: $ns_pos, $ew_pos  Facing: ".$compass->[$facing]."  -> $command $distance\n";

  if ($command eq 'F')    { $command = $compass->[$facing]; }

  if ($command eq 'N')    { $ns_pos += $distance; }
  elsif ($command eq 'S') { $ns_pos -= $distance; }
  elsif ($command eq 'E') { $ew_pos += $distance; }
  elsif ($command eq 'W') { $ew_pos -= $distance; }
  elsif ($command eq 'R') { $facing = (($facing + (-1 * $distance / 90)) % 4); }
  elsif ($command eq 'L') { $facing = (($facing + ($distance / 90)) % 4); } 
}

my $ns_dir = $ns_pos > 0 ? "North" : "South";
$ns_pos = abs($ns_pos);

my $ew_dir = $ew_pos > 0 ? "East"  : "West";
$ew_pos = abs($ew_pos);

print "Manhattan distance $ns_pos $ns_dir, $ew_pos $ew_dir : ".($ns_pos + $ew_pos)."\n";
