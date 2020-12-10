#!/usr/bin/perl -Tw

my @adapters;

while (my $next = <STDIN>) {
  chomp $next;
  push @adapters, $next;
}

my $current = 0;

my %diffs;

for my $adapter (sort { $a <=> $b } @adapters) {
  my $diff = $adapter - $current;
  $diffs{$diff} += 1;
  $current = $adapter;
}
# final adapter rated 3 jolts higher so include one more 3-jolt difference
$diffs{3} += 1; 

print join "\n", map { "Adapter of $_ jolt(s) = ".$diffs{$_} } sort { $a <=> $b } keys %diffs;
print "\n1-jolt * 3-jolts = ".($diffs{1} * $diffs{3})."\n";
