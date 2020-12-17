#!/usr/bin/perl -wT

my $grid;

my $limits = {
  min_z => 101, max_z => 101,
  min_y => 100, max_y => 100,
  min_x => 100, max_x => 100,
};

my ($z,$y,$x) = (101,100,100);
while(my $line = <STDIN>) {
  chomp $line;
  my $x = 100;
  foreach my $char (split '', $line) {
    $grid->[$z]->[$y]->[$x] = $char;
    $limits->{max_x} = $x++;
  } 
  $limits->{max_y} = $y++;
}

# widen workspace
$limits->{min_z}--;
$limits->{max_z}++;
$limits->{min_y}--;
$limits->{max_y}++;
$limits->{min_x}--;
$limits->{max_x}++;

# run 6 power cycles
for my $cycle (1..6) {
  runcycle($grid, $limits);
}

print count_active($grid, $limits)." are active\n";

sub runcycle {
  my ($grid, $limits) = @_;

  my $changes = ();
  
  # look at every position
  for my $z ($limits->{min_z}..$limits->{max_z}) {
    for my $y ($limits->{min_y}..$limits->{max_y}) {
      for my $x ($limits->{min_x}..$limits->{max_x}) {
      
        # now look at all 26 positions AROUND that position
        # to count number of active neighbors
        my $active_neighbors = 0;
        for my $dz (-1..1) {
          for my $dy (-1..1) {
            for my $dx (-1..1) {
              next if $dz == 0 && $dy == 0 && $dx == 0;
              $active_neighbors++ if ($grid->[$z+$dz]->[$y+$dy]->[$x+$dx]//'.') eq '#';
            }
          }
        }
        
        # mark power cycle changes to make
        if (($grid->[$z]->[$y]->[$x]//'.') eq '#') {
          if ($active_neighbors < 2 || $active_neighbors > 3) {
            push @$changes, { x => $x, y => $y, z => $z, set => '.' };
          }
        }                               
        else {
          if ($active_neighbors == 3) {
            push @$changes, { x => $x, y => $y, z => $z, set => '#' };
          }
          elsif (!$grid->[$z]->[$y]->[$x]) {
            push @$changes, { x => $x, y => $y, z => $z, set => '.' };
          }
        }             
      }
    }
  }
  
  # ok, ready to apply ALL changes
  for my $change (@$changes) {
    $grid->[$change->{z}]->[$change->{y}]->[$change->{x}] = $change->{set};
  }
  
  # we pushed limits out by 1 in every
  # direction by running this cycle
  foreach my $key (keys %$limits) {
    $key =~ /min/ ? $limits->{$key}-- : $limits->{$key}++;
  }
}

sub count_active {
  my ($grid, $limits) = @_;

  my $count = 0;

  for my $z ($limits->{min_z}..$limits->{max_z}) {
    for my $y ($limits->{min_y}..$limits->{max_y}) {
      for my $x ($limits->{min_x}..$limits->{max_x}) {
        $count++ if ($grid->[$z]->[$y]->[$x]//'.') eq '#';
      }
    }
  }
  return $count;
}
      
