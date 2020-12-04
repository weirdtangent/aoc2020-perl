#!/usr/bin/perl -Tw

my %numbers;

while (<STDIN>) {
  chomp;
  $numbers{$_}+=1;
}

for my $num1 (keys %numbers) {
  for my $num2 (keys %numbers) {
    next if $num1 == $num2 || 2020-$num1-$num2 == $num1;
    die sprintf ("%d + %d + %d = 2020, so multiplied = %d\n",
      $num1, $num2, 2020-$num1-$num2, $num1 * $num2 * (2020-$num1-$num2))
      if exists $numbers{2020-$num1-$num2};
  }
}
