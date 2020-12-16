#!/usr/bin/perl -Tw

my %rules;
my @nearby;

while (my $line = <STDIN>) {
  chomp $line;
  last if $line eq '';
  if ($line =~ /^([^:]+): (\d+)-(\d+) or (\d+)-(\d+)/) {
    $rules{$1} = [ { from => $2, to => $3 }, { from => $4, to => $5 } ];
  }
}

<STDIN>; # your ticket:
my $myticket = <STDIN>;
chomp $myticket;

<STDIN>; # blank line
<STDIN>; # nearby tickets:

while (my $line = <STDIN>) {
  chomp $line;
  push @nearby, $line;
}

# count the numbers on nearby tickets that are not
# valid for ANY ranges from ANY fields
for my $ticket (@nearby) {
  for my $value (split ',', $ticket) {
    $total += $value unless valid_value($value, \%rules);
  }
}

print "$total invalid values from nearby tickets\n";

# determine if ALL values on ticket are valid for SOME field
# or if some value on the ticket is invalid for everything
sub valid_value {
  my ($value, $rules) = @_;

  my $valid = 0;
  for my $rule (keys %$rules) {
    for my $check (@{$rules->{$rule}}) {
      $valid = 1 if $value >= $check->{from} && $value <= $check->{to};
    }
  }
  return $valid;
}




# departure location: 33-430 or 456-967
# departure station: 42-864 or 875-957
# departure platform: 42-805 or 821-968
# departure track: 34-74 or 93-967
# departure date: 40-399 or 417-955
# departure time: 30-774 or 797-950
# arrival location: 50-487 or 507-954
# arrival station: 34-693 or 718-956
# arrival platform: 42-729 or 751-959
# arrival track: 28-340 or 349-968
# class: 49-524 or 543-951
# duration: 40-372 or 397-951
# price: 48-922 or 939-951
# route: 33-642 or 666-960
# row: 39-238 or 255-973
# seat: 48-148 or 161-973
# train: 50-604 or 630-971
# type: 29-299 or 316-952
# wagon: 45-898 or 921-966
# zone: 34-188 or 212-959
#
# your ticket:
# 137,173,167,139,73,67,61,179,103,113,163,71,97,101,109,59,131,127,107,53
#
# nearby tickets:
# 122,945,480,667,824,475,800,224,297,602,673,513,641,524,835,981,54,184,60,721
# 692,125,595,331,803,765,721,249,729,162,226,523,821,137,297,588,296,299,720,318
