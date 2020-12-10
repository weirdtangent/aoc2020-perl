#!/usr/bin/perl -Tw

my $adapters;

while (my $next = <STDIN>) {
  chomp $next;
  push @$adapters, $next;
}
$adapters = [ sort { $a <=> $b } @$adapters ];

# add artifical starting and ending points
# so we can count ALL of the diffs
unshift @$adapters, 0;
push @$adapters, $adapters->[-1] + 3;

my $permutations = { 1 => 1, 2 => 2, 3 => 4, 4 => 7 };
my $current = $adapters->[0];
my $onecounts = {};
my $ones = 0;

# count strings of diffs of ones 
for my $adapter (@$adapters) {
  # if diff is 1, add to ones count
  if ($adapter - $current == 1) { $ones++; }
  # otherwise, if we have a count, increment string-of-ones counter and reset
  elsif ($ones) { $onecounts->{$ones}++; $ones=0; }
  # add this adapter so we can try the new one
  $current = $adapter;
}

# number of permutations ^ count, all multiplied together
my $paths = 1;
for $ones (keys %$onecounts) {
  $paths *= ($permutations->{$ones} ** $onecounts->{$ones});
}

print join(',', @$adapters)."\n\n";
print "We found $paths paths\n";
