#!/usr/bin/perl -Tw

my %group_questions;
my %group_count;
my $count=0;
my $groupnum=0;

while (my $line = <STDIN>) {
  chomp $line;
  if ($line eq '') {
    $groupnum++;
    $group_questions{$groupnum} = $string;
    $group_count{$groupnum} = $count;
    $string = '';
    $count=0;
  } else {
    $count+=1;
    $string .= $line;
  }
}
$groupnum++;
$group_questions{$groupnum} = $string;
$group_count{$groupnum} = $count;

my $total=0;
foreach my $groupnum (keys %group_questions) {
  my %questions;
  for my $question (split '', $group_questions{$groupnum}) {
    $questions{$question} += 1;
  }
  for my $question (keys %questions) {
    $total += 1
      if $questions{$question} == $group_count{$groupnum};
  }
}
print "$total answered yes from everyone in their group\n";
