#!/usr/bin/perl -Tw

use List::Util qw/min/;

my $earliest = <STDIN>;
chomp $earliest;

my $schedule = <STDIN>;
chomp $schedule;

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
    next if $bus_ids[$x] =~ /\D/;
    push @busses, $x;
}
print "Bus IDs: ",join(',', @bus_ids)."\n";
print "Busses to process: ",join(',', @busses)."\n\n";

my ($prod, $mults);
my $first;
my $second;

# process first two busses in findFirstT
# remaining busses can ammend the answer one at a time with findNextT
for my $x (0..@busses-1) {
  if (not defined $first) {
    $first = $busses[$x];
  }
  elsif (not defined $second) {
    $second = $busses[$x];
    ($prod, $mults) = findFirstT($first, $second, \@bus_ids);
  }
  else {
    ($prod, $mults) = findNextT($prod, $mults, $busses[$x], \@bus_ids);
  }
}

print "\nEarliest timestamp that matches is $prod\n";


sub findFirstT {
  my ($bus1, $bus2, $bus_ids) = @_;

  my $bus1_id = $bus_ids->[$bus1]; # problem only makes sense when FIRST bus is bus (T+0), so $bus1 should always be 0
  my $bus2_id = $bus_ids->[$bus2];

  print "findFirstT with busses $bus1 and $bus2 (IDs $bus1_id and $bus2_id)\n";

  my $prod;

  my $T = 0;
  do {
    $T++;
    $prod = $bus1_id * $T;
  } while (($prod - $bus1 + $bus2) % $bus2_id);
  my $mults = $bus1_id * $bus2_id;

  # print "$bus1_id * $T = $prod\n";
  # print "$bus2_id * ".(($prod + $bus2) / $bus2_id)." = ".($bus2_id * (($prod + $bus2) / $bus2_id))."\n";
  # print "and increases by multiples of $mults\n\n";

  return ($prod, $mults);
}


sub findNextT {
  my ($prod, $mults, $nextbus, $bus_ids) = @_;

  my $bus_id = $bus_ids->[$nextbus];
  print "findNextT adding bus $nextbus (IDs $bus_id)\n";

  while (($prod + $nextbus) % $bus_id) {
    $prod += $mults;
  }
  $mults *= $bus_id;
    
  # print "prod now $prod\n";
  # print "and now increases by multiples of $mults\n\n";

  return ($prod, $mults);
}
