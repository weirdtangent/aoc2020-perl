#!/usr/bin/perl -Tw

my @stack;
my @full;

for (1..25) {
  my $line = <STDIN>;
  chomp $line;
  push @stack, $line;
}

@full = @stack;

while (my $next = <STDIN>) {
  chomp $next;
  if (!check_sum($next, @stack)) {
    print "Found invalid sum: $next\n";
    if (my $ans = find_contig($next, @full)) {
      print "first + last = $ans\n";
      exit;
    }
    # otherwise, we failed
    else { die "Failed"; }
  }
  # remove top of stack and add to bottom
  shift @stack;
  push @stack, $next;
  # keep adding to full
  push @full, $next;
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

sub find_contig {
  my ($next, @stack) = @_;

  my $sum = 0;
  my $e1 = 0;
  my $e2 = 1;

  $sum += $stack[$e1];
  while (1) {
    # add next from e2 ptr to sum
    $sum += $stack[$e2];
    # right answer ?
    return minmax($e1, $e2, @stack) if $sum == $next;
    # if too much
    while ($sum > $next) {
      # subtract from e1 ptr and advance it one
      $sum -= $stack[$e1++];
    }
    # right answer ?
    return minmax($e1, $e2, @stack) if $sum == $next;
    # advance e2 ptr
    $e2++;
    # did we go too far?
    die "Failed" if $e2 > scalar(@stack);
  }
}

sub minmax {
  my ($e1, $e2, @stack) = @_;

  my $min;
  my $max;

  for (my $e=$e1; $e<=$e2; $e++) {
    $min = $stack[$e] if !$min || $min > $stack[$e];
    $max = $stack[$e] if !$max || $max < $stack[$e];
  }
  return $min + $max;
}
