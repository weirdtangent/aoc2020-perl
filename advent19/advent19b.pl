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
        # we have to have the subrule defined OR not if it is ourself!!
        $haveall = 0 unless $rules{$subrule} || $subrule == $rulenum;
      }
    }

    # ok to build the rule if we "have all" we need
    if ($haveall) {
      $count++;

      # build this rule wrapped in () with | between each version
      my $rulestring = '';
      my $lastrulestring = '';
      $rulestring .= '(';
      foreach my $version (@{$ruledefs{$rulenum}}) {
        $rulestring .= '|' if length($rulestring) > 1;
        foreach my $subrule (@$version) {
          # if we need to include ourself here, place "Q" placeholder
          $rulestring .= ($subrule == $rulenum ? 'Q' : $rules{$subrule});
        }
      }
      $rulestring .= ')';
      # if "Q" placeholder was left, we need to replace it with ourself
      # now that we are finished. Of course, that means what we replace it
      # with will have a "Q" too.
      # We need to replace it enough times to match the longest message we
      # might need to match - trial and error puts that at 5 times
      if ($rulestring =~ /Q/) {
        $rulestring =~ s/Q/$rulestring/;
        $rulestring =~ s/Q/$rulestring/;
        $rulestring =~ s/Q/$rulestring/;
        $rulestring =~ s/Q/$rulestring/;
        $rulestring =~ s/Q/$rulestring/;
        $rulestring =~ s/Q//;
      }
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
