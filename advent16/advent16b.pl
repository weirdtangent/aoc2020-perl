#!/usr/bin/perl -Tw

my %rules;
my @nearby;
my @numbers;
my @titles;

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
my @myticketnums = split ',', $myticket;

<STDIN>; # blank line
<STDIN>; # nearby tickets:

while (my $line = <STDIN>) {
  chomp $line;
  push @nearby, $line;
}

# drop out the tickets that have a number invalid for any field range
for my $ticket (@nearby) {
  my $valid = 1;
  for my $value (split ',', $ticket) {
    $valid = 0 unless valid_value($value, \%rules);
  }

  # collect numbers from valid tickets into individal arrays by field #
  if ($valid) {
    my $count = 0;
    for my $value (split ',', $ticket) {
      push @{$numbers[$count++]}, $value;
    }
  }
}

# determine which fields all possible for the group of values from valid tickets
for my $x (0..scalar(@numbers)-1) {
  print "Check " . scalar(@{$numbers[$x]}) . " numbers for field $x\n";
  my $possibles = which_field($numbers[$x], \%rules);
  push @{$titles[$x]}, @$possibles;
}

# each time we have only a single choice for a field #'s title
# remove THAT choice from all others, and loop again until
# we have a single choice for every field
my $allsingles = 0;
my %seen;
do {
  $allsingles = 1;
  for my $x (0..scalar(@titles)-1) { 
    if (scalar(@{$titles[$x]}) == 1) {
      if (not exists $seen{$titles[$x]->[0]}) {
        print $titles[$x]->[0]." is just in one field, we can remove it from others\n";
        $seen{$titles[$x]->[0]} = 1;
      }
    }
    else {
      print "Field $x still has ".scalar(@{$titles[$x]} )." fields\n";
      $allsingles = 0;
      my @new;
      foreach my $item (@{$titles[$x]}) {
        push @new, $item unless $seen{$item};
      }
      $titles[$x] = \@new;
    }
  }
} while !$allsingles;

print "\n";

# loop thru final version of ticket field names
# for "departure*" fields, multiple those numbers
# together from MY ticket and print total
my $totalnum = 1;
for my $x (0..scalar(@titles)-1) { 
  print "Field $x could be : ".join(',', @{$titles[$x]})."\n";
  if ($titles[$x]->[0] =~ /departure/) {
    print "  ".$titles[$x]->[0]." on my ticket is ".$myticketnums[$x]."\n";
    $totalnum*=$myticketnums[$x];
  }
}
print "Total is $totalnum\n";

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

# return the possible field titles that the entire list of
# numbers is valid for
sub which_field {
  my ($values, $rules) = @_;

  my @possibles;

  for my $rule (sort keys %$rules) {
    my $valid = 0;
    for my $value (@$values) {
      for my $check (@{$rules->{$rule}}) {
        $valid++,next if $value >= $check->{from} && $value <= $check->{to};
      }
    }
    push @possibles, $rule if $valid == scalar(@$values);
  }
  return \@possibles;
}
