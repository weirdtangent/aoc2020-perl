#!/usr/bin/perl -Tw

my $floorplan;

while (my $line = <STDIN>) {
  chomp $line;
  my @seats = split '', $line;
  push @$floorplan, \@seats;
}

my $rounds = 0;
my $changes = 0;

print "People are shuffling around in seats...\n";
do {
  $rounds++;
  $changes = run_round($floorplan);
} while $changes;

print "After $rounds rounds no more seating changes occuring.\n";
print "There are ".count_occupied_seats($floorplan) . " occupied seats.\n";


sub run_round {
  my $floorplan = shift;

  my @changes;

  for my $row (0..(scalar(@$floorplan)-1)) {
    for my $seat (0..(scalar(@$floorplan)-1)) {
      next if $floorplan->[$row]->[$seat] eq '.';
      # Look 8 directions for first actual seat
      my $adjacent = count_occupied_adjacent($row, $seat, $floorplan);

      # Add change to to-do list
      #   if no one around, empty seat will fill
      #   if 5+ seats occupied, a filled seat will empty
      if ($adjacent >= 5 && $floorplan->[$row]->[$seat] ne 'L') {
        push @changes, { row => $row, seat => $seat, set => 'L' };
      }
      elsif ($adjacent == 0 && $floorplan->[$row]->[$seat] ne '#') {
        push @changes, { row => $row, seat => $seat, set => '#' };
      }
    }
  }

  # Now that we have checked all seats
  # we can actually apply the changes we scheduled
  for my $change (@changes) {
    $floorplan->[$change->{row}]->[$change->{seat}] = $change->{set};
  }

  return scalar(@changes);
}

sub count_occupied_adjacent {
  my ($row, $seat, $floorplan) = @_;

  my $total_occupied = 0;

  # look 8 directions around seat
  for my $x (-1..1) {
    for my $y (-1..1) {
      next if $x == 0 && $y == 0;
      my ($check_x, $check_y) = ($row,$seat);
      my $is_occupied;
      # keep checking until we find a seat or go off the edge
      do {
        $check_x += $x;
        $check_y += $y;
        $is_occupied = is_occupied_seat($check_x, $check_y, $floorplan);
      } while $is_occupied < 0;
      $total_occupied += $is_occupied;
    }
  }

  return $total_occupied;
}

sub is_occupied_seat {
  my ($row, $seat, $floorplan) = @_;

  my $max_row = scalar(@$floorplan)-1;
  my $max_seat = scalar(@$floorplan)-1;

  # off the edge means not occupied
  return 0 if ($row < 0 || $seat < 0 || $row > $max_row || $seat > $max_seat);

  # not a seat if we found floor
  return -1 if $floorplan->[$row]->[$seat] eq '.';

  # return if occupied or not
  return $floorplan->[$row]->[$seat] eq '#';
}


sub count_occupied_seats {
  my $floorplan = shift;

  my $count = 0;

  for my $row (@$floorplan) {
    $count += scalar(grep /#/, @$row);
  }

  return $count;
}
