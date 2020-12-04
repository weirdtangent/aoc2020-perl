#!/usr/bin/perl -Tw

my @passports;
my $string='';
my $valid=0;

while (my $line = <STDIN>) {
  chomp $line;
  if ($line eq '') {
    push @passports, $string if $string;
    $string = '';
  } else {
    $string .= ($string ? ' ' : '') . $line;
  }
}
push @passports, $string if $string;

foreach my $passport (@passports) {
  my @pairs = split /\s+/, $passport;
  my %fields = ();
  foreach my $pair (@pairs) {
    my ($field, $value) = split /:/, $pair;
    next unless $value && grep /$field/, qw/byr iyr eyr hgt hcl ecl pid/;
    $fields{$field} = $value;
  }
  $valid+=1 if scalar(keys %fields) == 7;
}
print "$valid valid passports\n";
