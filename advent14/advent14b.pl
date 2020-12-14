#!/usr/bin/perl -Tw

my $count = 0;
my @mask;
my %memory;

while (my $line = <STDIN>) {
  chomp $line;
  print "Input: $line\n";
  if ($line =~ /^mask = ([01X]+)/) {
    @mask = split '', $1;
    print "Set mask to : ".join('', @mask)."\n";
  }
  elsif ($line =~ /^mem\[(\d+)\] = (\d+)/) {
    my ($key, $value) = ($1, $2);
    @bits = into_bits($key);
    @bits = apply_mask(\@bits, \@mask);
    my $random;
    my @variants = ('');
    for my $bitpos (0..35) {
      if ($bits[$bitpos] =~ /[01]/) {
        $_ .= $bits[$bitpos] foreach @variants;
      }
      else {
        my @add = @variants;
        $_ .= '0' foreach @variants;
        $_ .= '1' foreach @add;
        push @variants, @add;
      }
    }
    my @valuebits = into_bits($value);
    $memory{$_} = join('', @valuebits) foreach @variants;
    print "Stored ".join('', @valuebits)." into ".scalar(@variants)." memory buckets\n";
  }
  else {
    print "Could not understand input: $line\n";
  }
}

# mask = 0101111110011010X110100010X100000XX0
# mem[46424] = 216719
# mem[43628] = 6647
# mem[21582] = 4737255
# mem[62945] = 25540
# mem[14304] = 1226

my $total = 0;
for my $key (keys %memory) {
  my $value = from_bits($memory{$key});
  $total += $value;
}
print "Total: $total\n";

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

sub apply_mask {
  my ($bits, $mask) = @_;

  print "Applying ".join('', @$mask)." to ".join('', @$bits)."\n";
  my @newbits;
  for my $bitpos (0..35) {
    if ($mask->[$bitpos] eq '0') {
      push @newbits, $bits->[$bitpos];
    }
    elsif ($mask->[$bitpos] eq '1') {
      push @newbits, '1';
    }
    else {
      push @newbits, 'X';
    }
  }

  print "  Returning ".join('', @newbits)."\n";
  return @newbits;
}

sub from_bits {
  my ($bitstring) = @_;

  my $value = 0;
  my $bitpos = 35;
  for my $bitchar (split '', $bitstring) {
    my $bitval = 2 ** $bitpos;
    if ($bitchar eq '1') {
      $value += $bitval;
    }
    $bitpos--;
  }

  return $value;
}

