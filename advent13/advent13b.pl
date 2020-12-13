#!/usr/bin/perl -Tw

use List::Util qw/min/;

my $earliest = <STDIN>;
chomp $earliest;

my $schedule = <STDIN>;
chomp $schedule;

my @busses = split(',', $schedule);

# Setup for Chinese Remainder Theorem
my @num;  # we want a single number x, that when x % num[n]
my @rem;  # will give us the answer rem[n]

my $prod=1;
my @pp;
my @inv;
my $total;
my $final; 

# setup num and rem... the remainder we expect is the num - position in the original array
for my $x (0..scalar(@busses)-1) {
  next if $busses[$x] =~ /\D/; 
  push @num, $busses[$x];
  push @rem, $busses[$x] - $x;
  $prod *= $busses[$x];
}

for my $x (0..scalar(@num)-1) {
  $pp[$x] = $prod / $num[$x];
  $inv[$x] = inv($pp[$x], $num[$x]);
  $total += ($rem[$x] * $pp[$x] * $inv[$x]);
}
$final = $total % $prod;

print "num:   ".join(',', @num)."\n";
print "rem:   ".join(',', @rem)."\n";
print "prod:  $prod\n";
print "pp:    ".join(',', @pp)."\n";
print "inv:   ".join(',', @inv)."\n";

print "\nanswer = $final\n";

# find Modular Multiplicative Invser of a with respect to m
sub inv {
  my ($a, $m) = @_;

  my $m0 = $m;
  my $t;
  my $q;
  my $x0 = 0;
  my $x1 = 1;

  return 0 if $m == 1;
  
  while ($a > 1) {
    $q = int($a / $m);
    $t = $m;
    $m = $a % $m;
    $a = $t;
    $t = $x0;
    $x0 = $x1 - $q * $x0;
    $x1 = $t;
  }
  $x1 += $m0 if $x1 < 0;
  return $x1;
}
