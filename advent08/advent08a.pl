#!/usr/bin/perl -Tw

my @code;
my $linenum=0;
my $acc=0;
my %track;

while (my $line = <STDIN>) {
  push @code, $line;
}

while (1) {
  die "infinite loop detected, acc = $acc\n"
    if exists $track{$linenum};

  $track{$linenum}+=1;

  my $line = $code[$linenum];
  my ($opcode, $sign, $value) = $line =~ /(\w+) ([-+])(\d+)/;
  
  if ($opcode eq 'nop') {
    $linenum++;
  }
  elsif ($opcode eq 'acc') {
    $acc += ($sign eq '+') ? $value : ($value * -1);
    $linenum++;
  }
  elsif ($opcode eq 'jmp') {
    $linenum += ($sign eq '+') ? $value : ($value * -1);
  }
}
