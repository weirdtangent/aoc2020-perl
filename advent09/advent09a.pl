#!/usr/bin/perl -Tw

my @stack;

for (1..25) {
  my $line = <STDIN>;
  chomp $line;
  push @stack, $line;
}

while (my $next = <STDIN>) {
  chomp $next;
  die "$next is not the sum of previous 25 numbers\n"
    unless check_sum($next, @stack);
  shift @stack;
  push @stack, $next;
}


sub check_sum {
  my ($next, @stack) = @_;

  for my $num1 (@stack) {
    for my $num2 (@stack) {
      next if $num1 == $num2;
      return 1 if $num1 + $num2 == $next;
    }
  }
  return 0;
}
