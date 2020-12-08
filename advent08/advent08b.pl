#!/usr/bin/perl -Tw

my @code;
my $change=0;

while (my $line = <STDIN>) {
  push @code, $line;
}

# try as-is
exit if trychange(-1, @code);

while (1) {
  die "Failed to fix!" if $change > scalar(@code);
  exit if trychange($change, @code);
  $change+=1;
}

sub trychange {
  my ($change, @code) = @_;

  $change < 0
    ? print "\nTry running as-is\n"
    : print "\nTry changing opcode #$change\n";

  my $linenum=0;
  my $changed_linenum=0;
  my $acc=0;
  my %track;
  my $opcount=0;
  my $maxlines = scalar(@code);

  while ($linenum < $maxlines) {
    if (exists $track{$linenum}) {
      print "infinite loop detected, about to run ".($linenum+1)." again, aborting with acc = $acc\n";
      return 0;
    }

    $track{$linenum}+=1;

    my $line = $code[$linenum];
    my ($opcode, $sign, $value) = $line =~ /(\w+) ([-+])(\d+)/;

    if ($change >= 0 && $opcount == $change) {
      if ($opcode eq 'nop')    { print "Changing nop to jmp\n"; $opcode='jmp' }
      elsif ($opcode eq 'jmp') { print "Changing jmp to nop\n"; $opcode='nop' }
      $changed_linenum = $linenum+1;
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

    $opcount++ if $opcode =~ /nop|jmp/;
  }

  $change < 0
    ? print "Hit end of code by running it as-is, acc = $acc\n"
    : print "Hit end of code by fixing line number $changed_linenum, acc = $acc\n";

  return 1;
}
