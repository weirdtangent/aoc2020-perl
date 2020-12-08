#!/usr/bin/perl -Tw

my @code;
my $change=0;

while (my $line = <STDIN>) {
  push @code, $line;
}

while (1) {
  trychange($change, @code);
  $change+=1;
}

sub trychange {
  my ($change, @code) = @_;

  print "\nTry changing opcode #$change\n";

  my $linenum=0;
  my $acc=0;
  my %track;
  my $opcount=0;
  my $maxlines = scalar(@code);

  while ($linenum < $maxlines) {
    if (exists $track{$linenum}) {
      print "infinite loop detected, aborting\n";
      return 0;
    }

    $track{$linenum}+=1;

    my $line = $code[$linenum];
    my ($opcode, $sign, $value) = $line =~ /(\w+) ([-+])(\d+)/;

    if ($opcount == $change) {
      if ($opcode eq 'nop')    { print "Changing nop to jmp\n"; $opcode='jmp' }
      elsif ($opcode eq 'jmp') { print "Changing jmp to nop\n"; $opcode='nop' }
    }

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

    $opcount++;
  }

  die "Hit end of code, acc = $acc\n";
}
