#!/usr/bin/perl -Tw

my $verbose = 0;
my @mask;
my %memory;

while (my $line = <STDIN>) {
  chomp $line;
  print "Input: $line\n" if $verbose;
  if ($line =~ /^mask = ([01X]+)/) {
    @mask = split '', $1;
    print "Set mask to : ".join('', @mask)."\n" if $verbose;
  }
  elsif ($line =~ /^mem\[(\d+)\] = (\d+)/) {
    my ($key, $value) = ($1, $2);
    @bits = into_bits($value);
    @bits = apply_mask(\@bits, \@mask);
    $memory{$key} = join('', @bits);
    print "Stored ".join('', @bits)." into memory at $key\n" if $verbose;
  }
  else {
    print "Could not understand input: $line\n";
  }
}

my $total = 0;
for my $key (keys %memory) {
  $total += from_bits($memory{$key});
}
print "Total: $total\n";

# convert value into 36-bit array
sub into_bits {
  my ($value) = @_;

  my @bits;
  for my $bitpos (0..35) {
    my $bitval = 2 ** (35-$bitpos);
    if ($value >= $bitval) {
      push @bits, 1;
      $value -= $bitval;
    }
    else {
      push @bits, 0;
    }
  }

  return @bits;
}

# apply mask to bits resulting in newbits to be returned
# all are 36-bit arrays
sub apply_mask {
  my ($bits, $mask) = @_;

  print "Applying ".join('', @$mask)." to ".join('', @$bits)."\n" if $verbose;
  my @newbits;
  for my $bitpos (0..35) {
    $mask->[$bitpos] =~ /[01]/
      ? push @newbits, $mask->[$bitpos]
      : push @newbits, $bits->[$bitpos];
  }

  return @newbits;
}

# convert string of 36-bits back into value
sub from_bits {
  my ($bitstring) = @_;

  my $value = 0;
  my $bitpos = 35;
  for my $bitchar (split '', $bitstring) {
    my $bitval = 2 ** $bitpos--;
    $value += $bitval if $bitchar eq '1';
  }

  return $value;
}

