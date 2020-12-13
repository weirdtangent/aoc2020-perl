#!/usr/bin/perl -Tw

my $earliest = <STDIN>;
chomp $earliest;

my $schedule = <STDIN>;
chomp $schedule;

my %bus_times = map { $_ => $_ } grep(/^\d+$/, split(',', $schedule));

my $bus_to_take;
my $bus_departs;

# just math it
for my $bus_id (keys %bus_times) {
  $bus_times{$bus_id} = ((int($earliest / $bus_id) + 1) * $bus_id - $earliest);
}

# find the minimal match
for my $bus_id (keys %bus_times) {
  if (!$bus_departs || $bus_times{$bus_id} < $bus_departs) {
    $bus_to_take = $bus_id;
    $bus_departs = $bus_times{$bus_id};
  }
}

print "Answer: ".($bus_to_take * $bus_departs)."\n";
