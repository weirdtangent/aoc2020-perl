#!/usr/bin/perl -wT

use List::MoreUtils qw(first_index);

my $line = '789465123';

my $cups = [ split '', $line ];
my $move = 0;
my $current_cup = 0;
my @pickedup = ();

while ($move < 100) {
  $move++;
  print "Move $move\n";
  print "  cups: ".join(',', @$cups)." ( and ".($current_cup+1)." is current)\n";
  my $current_label = $cups->[$current_cup];
  @$pickedup = splice @$cups, $current_cup+1, 3;
  push @$pickedup, shift @$cups while (@$pickedup < 3);

  print "  picked up: ".join(',', @$pickedup)."\n";
  my $find_cup = $current_label;
  do {
    $find_cup--;
    $find_cup = 9 if $find_cup < 1;
  } while grep /$find_cup/, @$pickedup;
  print "  destination: $find_cup\n";
  splice @$cups, (first_index { $_ eq $find_cup } @$cups) + 1, 0, @$pickedup;
  while ($cups->[$current_cup] ne $current_label) {
    push @$cups, shift @$cups;
  }
  $current_cup++;
  $current_cup %= scalar(@$cups);
  print "\n";
}

print "final: ".join(',', @$cups)."\n\n";

while ($cups->[0] ne '1') {
  push @$cups, shift @$cups;
}
print "Cups after '1' are: ".join('', @$cups[1..@$cups-1])."\n";
