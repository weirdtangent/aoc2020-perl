#!/usr/bin/perl -Tw

my @groups;

while (my $line = <STDIN>) {
  chomp $line;
  if ($line eq '') {
    push @groups, $string if $string;
    $string = '';
  } else {
    $string .= $line;
  }
}
push @groups, $string if $string;

foreach my $group (@groups) {
  my %questions = map { $_ => 1 } split '', $group;
  my $count = scalar(keys %questions);
  $total += $count;
}
print "$total total questions from all groups\n";
