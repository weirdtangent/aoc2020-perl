#!/usr/bin/perl -wT

my $verbose = 0;

my $total = 0;
while(my $line = <STDIN>) {
  chomp $line;
  $total += precalc($line);
}

print "total is $total\n";

sub precalc {
  my ($line) = @_;

  print "Solve $line\n" if $verbose;

  $line =~ tr/\(/S/;
  $line =~ tr/\)/E/;

  while ($line =~ /[SE\+\*]/) {
    next if $line =~ s/(S([^SE]+)E)/calc($2)/e;
    next if $line =~ s/(\d+ [\+\*] \d+)/calc($1)/e;
    next if $line =~ s/S(\d+)E/$1/g;
  }
  return $line+0;
}
  
sub calc {
  my ($line) = @_;

  my $total = 0;
  my $command='';

  print "  first solve $line\n" if $verbose;
  for my $op (split ' ', $line) {
    $command = $op if $op =~ /[\+\*]/;
    if ($op =~ /^\d+$/) {
      $total = $op if $command eq '';
      $total += $op if $command eq '+';
      $total *= $op if $command eq '*';
    }
  }
  return $total;
}

