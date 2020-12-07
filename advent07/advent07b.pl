#!/usr/bin/perl -Tw

my $bags;

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
my $total = count_inside('shiny gold', $bags, 1);

print "\n$total bags inside a shiny gold bag\n";

sub count_inside {
  my ($color, $bags, $level) = @_;

  return 0
    unless my $contents = $bags->{$color};
  print ' ' x $level."counting what's inside $color bags: ".join(',', map { $contents->{$_}." $_" } keys %$contents)."\n";

  my $count=0;
  for my $inside (keys %$contents) {
    my $inside_count = $contents->{$inside};
    my $plus = count_inside($inside, $bags, $level+1);
    $count += $inside_count + ($inside_count * $plus);
  }

  print ' ' x $level."$count bags inside $color bags.\n";
  return $count;
}
