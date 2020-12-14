#!/usr/bin/perl -Tw

my $earliest = <STDIN>;
chomp $earliest;

my $schedule = <STDIN>;
chomp $schedule;

# swap out all 'x' (unidentified) busses with 1
# which won't affect answer but makes array processing
# much easier without having to skip bad busses
$schedule =~ s/x/1/g;

my @bus_ids = split(',', $schedule);
my @bus_times = @bus_ids;

## Using this hint from reddit, trying to solve on my own
## without some Chinese Remainder Theory or whatever
##
## Previous bus is 7, this bus is 13, with delay +1.
## A time T is needed such that:
##      7x == T
##     13y == (T + 1)
##
## Performing an iterative search for T on multiples of 7 and checking (T + 1)
## eventually reveals that:
##   (7 * 11) == 77
##   (13 * 6) == 78
##
## To find further times that match this condition, imagine some value W added to T.
##    7j == T + W
##   13k == (T + 1) + W

my @busses;
for my $x (0..@bus_ids-1) {
    push @busses, $x unless $bus_ids[$x] =~ /\D/;
}

# process first two busses in findFirstT
# then, remaining busses can ammend the answer one at a time with findNextT
my ($prod, $mults) = findFirstT(0, 1, \@bus_ids);
for my $x (2..@busses-1) {
  ($prod, $mults) = findNextT($prod, $mults, $busses[$x], \@bus_ids);
}

print "\nEarliest timestamp that matches is $prod\n";


sub findFirstT {
  my ($bus1, $bus2, $bus_ids) = @_;

  my $bus1_id = $bus_ids->[$bus1]; # problem only makes sense when FIRST bus is bus (T+0), so $bus1 should always be 0
  my $bus2_id = $bus_ids->[$bus2];

  my $T = 1;
  my $prod;
  do {
    $prod = $bus1_id * $T++;
  } while (($prod - $bus1 + $bus2) % $bus2_id);
  my $mults = $bus1_id * $bus2_id;

  return ($prod, $mults);
}


sub findNextT {
  my ($prod, $mults, $nextbus, $bus_ids) = @_;

  my $bus_id = $bus_ids->[$nextbus];

  while (($prod + $nextbus) % $bus_id) {
    $prod += $mults;
  }
  $mults *= $bus_id;
    
  return ($prod, $mults);
}
