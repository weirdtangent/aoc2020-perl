#!/usr/bin/perl -wT

my %ruledefs;  # definitions from input file
my %rules;     # constructed patterns
my @messages;  # messages to validate

# read ruledefs
while(my $line = <STDIN>) {
  chomp $line;
  last if $line eq '';
  if ($line =~ /(\d+): "(\w)"$/) {
    $rules{$1} = $2;
  }
  elsif ($line =~ /(\d+): (.*)/) {
    my $rulenum = $1;
    my $rulestring = $2;
    my $versionnum = 0;
    foreach my $version (split /\|\s+/, $rulestring) {
      foreach my $number (split /\s+/, $version) {
        push @{$ruledefs{$rulenum}->[$versionnum]}, $number;
      }
      $versionnum++;
    }
  }
}

# read message
while(my $line = <STDIN>) {
  chomp $line;
  push @messages, $line;
}

# convert ruledefs into rules
while (1) {
  my $count = 0;
  foreach my $rulenum (keys %ruledefs) {
    my $haveall = 1;
    foreach my $version (@{$ruledefs{$rulenum}}) {
      foreach my $subrule (@$version) {
        $haveall = 0 unless $rules{$subrule};
      }
    }

    # ok to build the rule if we "have all" we need
    if ($haveall) {
      $count++;

      # build this rule wrapped in () with | between each version
      my $rulestring = '';
      $rulestring .= '(';
      foreach my $version (@{$ruledefs{$rulenum}}) {
        $rulestring .= '|' if length($rulestring) > 1;
        foreach my $subrule (@$version) {
          $rulestring .= $rules{$subrule};
        }
      }
      $rulestring .= ')';
      $rules{$rulenum} = $rulestring;

      # we built the rule, lets remove it from the definitions since its done
      delete $ruledefs{$rulenum};
    }
  }

  # continue until we don't construct a single rule during a loop
  last unless $count;
}

my $match = 0;
foreach my $message (@messages) {
  $match++ if ($message =~ /^$rules{'0'}$/)
}

print "$match match rule 0\n";
