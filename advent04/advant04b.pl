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

  next unless scalar(keys %fields) == 7;

  next unless $fields{byr} =~ /^\d{4}$/ && $fields{byr} >= 1920 && $fields{byr} <= 2002;
  next unless $fields{iyr} =~ /^\d{4}$/ && $fields{iyr} >= 2010 && $fields{iyr} <= 2020;
  next unless $fields{eyr} =~ /^\d{4}$/ && $fields{eyr} >= 2020 && $fields{eyr} <= 2030;

  my ($h_num, $h_unit) = $fields{hgt} =~ /^(\d+)(in|cm)$/;
  next unless $h_num && $h_unit;
  next unless (($h_unit eq 'cm' && $h_num >= 150 && $h_num <= 193)
            || ($h_unit eq 'in' && $h_num >= 59 && $h_num <= 76));

  next unless $fields{hcl} =~ /^\#[0-9a-f]{6}$/;
  next unless grep /$fields{ecl}/, qw/amb blu brn gry grn hzl oth/;
  next unless $fields{pid} =~ /^\d{9}$/;

  $valid+=1;
}
print "$valid valid passports\n";
