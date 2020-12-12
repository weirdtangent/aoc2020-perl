#!/usr/bin/perl -Tw

my $compass = [ 'N', 'W', 'S', 'E' ];
my $ship_ns_pos = 0;
my $ship_ew_pos = 0;
my $waypoint_ns_pos = 1;
my $waypoint_ew_pos = 10;

while (my $line = <STDIN>) {
  chomp $line;
  my ($command, $distance) = $line =~ /^(\w)(\d+)/;
  print "Ship: $ship_ns_pos, $ship_ew_pos  Waypoint: $waypoint_ns_pos, $waypoint_ew_pos  -> $command $distance\n";

  if ($command eq 'N')    { $waypoint_ns_pos += $distance; }
  elsif ($command eq 'S') { $waypoint_ns_pos -= $distance; }
  elsif ($command eq 'E') { $waypoint_ew_pos += $distance; }
  elsif ($command eq 'W') { $waypoint_ew_pos -= $distance; }
  elsif ($command eq 'L') {
    for (1..($distance / 90)) {
      my $save_ns = $waypoint_ns_pos;
      my $save_ew = $waypoint_ew_pos;
      $waypoint_ew_pos = $save_ns * -1;
      $waypoint_ns_pos = $save_ew;
    }
  }
  elsif ($command eq 'R') {
    for (1..($distance / 90)) {
      my $save_ns = $waypoint_ns_pos;
      my $save_ew = $waypoint_ew_pos;
      $waypoint_ew_pos = $save_ns;
      $waypoint_ns_pos = $save_ew * -1;
    }
  }
  elsif ($command eq 'F') {
    $ship_ns_pos += $distance * $waypoint_ns_pos;
    $ship_ew_pos += $distance * $waypoint_ew_pos;
  }
}

my $ship_ns_dir = $ship_ns_pos > 0 ? "North" : "South";
$ship_ns_pos = abs($ship_ns_pos);

my $ship_ew_dir = $ship_ew_pos > 0 ? "East"  : "West";
$ship_ew_pos = abs($ship_ew_pos);

print "Manhattan distance $ship_ns_pos $ship_ns_dir, $ship_ew_pos $ship_ew_dir : ".($ship_ns_pos + $ship_ew_pos)."\n";
