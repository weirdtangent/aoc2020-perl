#!/usr/bin/perl -Tw

my $max = 0;
my %seats;

while (my $line = <STDIN>) {
  my ($low, $high) = (0,127);
  my ($left, $right) = (0,7);
  chomp $line;
  for my $chr (split '', $line) {
    my $half_row = int(($high-$low+1)/2);
    my $half_seat = int (($right-$left+1)/2);
    if ($chr eq 'F') {
      $high -= $half_row;
    }
    elsif ($chr eq 'B') {
      $low += $half_row;
    }
    elsif ($chr eq 'L') {
      $right -= $half_seat;
    }
    elsif ($chr eq 'R') {
      $left += $half_seat;
    }
  }
  my $seat_id = (($low * 8) + $left);
  $seats{$seat_id} += 1;
}

for my $seat_id (sort { $a <=> $b } keys %seats) {
  print "Missing seat id = ".($seat_id+1)."\n"
    if !$seats{$seat_id+1} && $seats{$seat_id+2};
}
