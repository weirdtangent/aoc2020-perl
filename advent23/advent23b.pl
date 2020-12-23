#!/usr/bin/perl -wT

use List::Util qw(max);
use List::MoreUtils qw(first_index);

# setup
my $move = 0;
my $max_cup = 1_000_000;
my $max_moves = 10_000_000;

my $line = '789465123';
my @labels = split '', $line;
my $max_label = max @labels;

# setup linked list for unique string above
$cups->{$labels[$_]} = { prev => $labels[$_ - 1], next => $labels[($_ + 1) % @labels] } for (0..@labels-1);

# add 10 - 1,000,000 to linked list
$cups->{$_} = { prev => $_ - 1, next => $_ + 1 } for (10..$max_cup);

# fix pointers for circular list
link_pointers($labels[-1], 10);
link_pointers($max_cup, $labels[0]);

my $current_label = $labels[0];

while ($move < $max_moves) {
  $move++;
  if ($move == 1 || $move % 1_000_000 == 0) {
    print "On move $move, current label = $current_label\n";
    print_list($current_label, 15);
    print "\n";
  }

  my @pickedup = ();
  for (my $target = $cups->{$current_label}->{next}; @pickedup < 3; $target = $cups->{$target}->{next}) {
    push @pickedup, $target;
  }

  my $find_cup = $current_label;
  do {
    $find_cup--;
    $find_cup = $max_cup if $find_cup < 1;
  } while (first_index { $_ eq $find_cup } @pickedup) >= 0;

  # skip over "picked up" string of numbers
  my $skip_to = follow($current_label, 4);
  link_pointers($current_label, $skip_to);

  # fix start of inserted string of numbers
  my $save_next = $cups->{$find_cup}->{next};
  link_pointers($find_cup, $pickedup[0]);

  # fix end of inserted string of numbers
  link_pointers($pickedup[2], $save_next);

  # advance label to next
  $current_label = $cups->{$current_label}->{next};
}

my $cup_1 = $cups->{1}->{next};
my $cup_2 = $cups->{$cup_1}->{next};

print "Two cups after cup labeled '1' are $cup_1 and $cup_2\n";
print $cup_1 * $cup_2;
print "\n";

sub link_pointers {
  my ($first, $second) = @_;

  $cups->{$first}->{next} = $second;
  $cups->{$second}->{prev} = $first;
}

# follow next pointers, $steps times
sub follow {
  my ($current, $steps) = @_;

  return $current unless $steps--;
  return follow($cups->{$current}->{next}, $steps);
}

# print a sampling list, starting at $current, for $max_steps
sub print_list {
  my ($current, $max_steps) = @_;

  my $end = $current;

  print '... ';
  do {
    print "$current ";
    $current = $cups->{$current}->{next};
  } while $current != $end && $max_steps--;
  print "...\n";
}
