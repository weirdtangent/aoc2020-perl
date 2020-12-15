#!/usr/bin/perl -Tw

my %number_count;
my %number_pos;
my $last_num;
my $count = 0;

my $line = <STDIN>;
chomp $line;
foreach (split ',', $line) {
  $number_count{$_}+=1;
  $number_pos{$_} = $count++;
  $last_num = $_;
}

#print "\n";

while ($count < 30000000) {
  my $num = ($number_count{$last_num} == 1) ? 0 : ($count - ($number_pos{$last_num}//0) - 1);
  $number_pos{$last_num} = $count-1;
  $number_count{$num}+=1;
  $last_num = $num;
  $count++;
}

print "Last number: $last_num\n";

