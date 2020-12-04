#!/usr/bin/perl -Tw

my %numbers;

while (<STDIN>) {
  chomp;
  $numbers{$_}+=1;
}

for my $num (keys %numbers) {
  die sprintf ("%d + %d = 2020, so multiplied = %d\n",
    $num, 2020-$num, $num * (2020-$num))
    if exists $numbers{2020-$num};
}
