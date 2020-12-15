#!/usr/bin/perl -Tw

my @numbers;
my %numbers;
my $last_num;

my $line = <STDIN>;
chomp $line;
foreach (split ',', $line) {
  push @numbers, $_;
  $numbers{$_}++;
  $last_num = $_;
}

while (scalar(@numbers) < 2020) {
  if ($numbers{$last_num} == 1) {
    push @numbers, 0;
    $numbers{0}++;
    $last_num = 0;
    next;
  }
  my $apart=1;
  for (my $i=scalar(@numbers)-2; $i>=0; $i--, $apart++) {
    if ($numbers[$i] == $last_num) {
      push @numbers, $apart;
      $numbers{$apart}++;
      $last_num = $apart;
      last;
    }
  }
}

print "Last number: $last_num\n";

