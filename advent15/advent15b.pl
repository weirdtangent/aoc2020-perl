#!/usr/bin/perl -Tw

my %number_pos;
my $last_num;
my $count = 0;

my $line = <STDIN>;
chomp $line;
foreach (split ',', $line) {
  $number_pos{$_} = $count++;
  $last_num = $_;
}

while ($count < 30000000) {
  my $num = (exists $number_pos{$last_num}) ? ($count - ($number_pos{$last_num}//0) - 1) : 0;
  $number_pos{$last_num} = ($count++)-1;
  $last_num = $num;
}

print "Last number: $last_num\n";

