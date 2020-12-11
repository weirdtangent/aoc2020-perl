#!/usr/bin/perl -Tw

my $floorplan;

while (my $line = <STDIN>) {
  chomp $line;
  my @seats = split '', $line;
  push @$floorplan, \@seats;
}

my $rounds = 0;
my $changes = 0;

do {
  # print_corner($floorplan);
  $rounds++;
  $changes = run_round($floorplan);
} while $changes;

die "After $rounds rounds, there are ".count_occupied($floorplan) . " occupied seats\n";


sub run_round {
  my $floorplan = shift;

  my @changes;

  for my $row (0..(scalar(@$floorplan)-1)) {
    for my $seat (0..(scalar(@$floorplan)-1)) {
      next if $floorplan->[$row]->[$seat] eq '.';
      my $adjacent = check_direction($row, $seat, $floorplan);

      if ($adjacent >= 5 && $floorplan->[$row]->[$seat] ne 'L') {
        push @changes, { row => $row, seat => $seat, set => 'L' };
      }
      elsif ($adjacent == 0 && $floorplan->[$row]->[$seat] ne '#') {
        push @changes, { row => $row, seat => $seat, set => '#' };
      }
    }
  }

  # print scalar(@changes)." changes to apply\n";

  for my $change (@changes) {
    $floorplan->[$change->{row}]->[$change->{seat}] = $change->{set};
  }

  return scalar(@changes);
}

sub check_direction {
  my ($row, $seat, $floorplan) = @_;

  my $total = 0;
  my ($x, $y, $result);

  ($x, $y) = (0,0);
  do { $x--, $y--; } while ($result = check($row+$x, $seat+$y, $floorplan)) < 0;
  $total += $result;

  ($x, $y) = (0,0);
  do { $y--; }       while ($result = check($row+$x, $seat+$y, $floorplan)) < 0;
  $total += $result;

  ($x, $y) = (0,0);
  do { $x++, $y--; } while ($result = check($row+$x, $seat+$y, $floorplan)) < 0;
  $total += $result;

  ($x, $y) = (0,0);
  do { $x--; }       while ($result = check($row+$x, $seat+$y, $floorplan)) < 0;
  $total += $result;

  ($x, $y) = (0,0);
  do { $x++; }       while ($result = check($row+$x, $seat+$y, $floorplan)) < 0;
  $total += $result;

  ($x, $y) = (0,0);
  do { $x--, $y++; } while ($result = check($row+$x, $seat+$y, $floorplan)) < 0;
  $total += $result;

  ($x, $y) = (0,0);
  do { $y++; }       while ($result = check($row+$x, $seat+$y, $floorplan)) < 0;
  $total += $result;

  ($x, $y) = (0,0);
  do { $x++, $y++; } while ($result = check($row+$x, $seat+$y, $floorplan)) < 0;
  $total += $result;

  return $total;
}

sub check {
  my ($row, $seat, $floorplan) = @_;

  my $max_row = scalar(@$floorplan)-1;
  my $max_seat = scalar(@$floorplan)-1;

  return 0 if ($row < 0 || $seat < 0 || $row > $max_row || $seat > $max_seat);

  die "Invalid seat? max is $max_row, $max_seat. Checking $row, $seat is undef" unless $floorplan->[$row]->[$seat];

  return 1 if $floorplan->[$row]->[$seat] eq '#';
  return 0 if $floorplan->[$row]->[$seat] eq 'L';
  return -1; # floor, keep looking
}


sub print_corner {
  my $floorplan = shift;

  my $count = 0;

  for my $row (0..(scalar(@$floorplan)-1)) {
    for my $seat (0..(scalar(@$floorplan)-1)) {
      print $floorplan->[$row]->[$seat];
    }
    print "\n";
  }
  print "\n";
}


sub count_occupied {
  my $floorplan = shift;

  my $count = 0;

  for my $row (0..(scalar(@$floorplan)-1)) {
    for my $seat (0..(scalar(@$floorplan)-1)) {
      $count++ if $floorplan->[$row]->[$seat] eq '#';
    }
  }

  return $count;
}
