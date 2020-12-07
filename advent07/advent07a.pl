#!/usr/bin/perl -Tw

use Data::Dumper;

my $bags;
my $total=0;

while (my $line = <STDIN>) {
  my ($key, $contents) = $line =~ /^(\w+ \w+) bags contain (.*)/;
  next if ($contents eq 'no other bags.');
  while ($contents) {
    my ($count, $color, $rest) = $contents =~ /(\d+) (\w+ \w+) bags?[,.](.*)/;
    $bags->{$key}->{$color} = $count;
    $contents = $rest//'';
  }
}

print "Loaded ".scalar(keys %$bags)." bag descriptions\n";

for my $color (keys %$bags) {
  if (can_carry_gold($color, $bags, 1)) {
    print "$color can carry a shiny gold bag\n";
    $total += 1;
  }
}

print "\n$total can carry at least 1 shiny gold bag.\n";

sub can_carry_gold {
  my ($color, $bags, $level) = @_;

  return 0
    unless my $contents = $bags->{$color};
  return 1
    if $contents->{'shiny gold'};
  for my $inside (keys %$contents) {
    return 1 if can_carry_gold($inside, $bags, $level+1);
  }
  return 0;
}
