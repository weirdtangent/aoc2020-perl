#!/usr/bin/perl -wT

use Array::Transpose;

our $verbose = 0;

our $tiles;
our $tiles_to_place;
our $image;

while(my $line = <STDIN>) {
  chomp $line;
  next unless $line =~ /Tile (\d+):/;
  my $tilenum = $1;
  my $row = 0;
  while ($line = <STDIN>) {
    chomp $line;
    last unless $line;
    push @{$tiles->{$tilenum}->[$row++]}, split '', $line;
  }
}

place_tiles();

my $mult = 1;
my $string = '';
foreach (find_corners()) {
  $string .= ($string ? ' * ' : '') . $_;
  $mult *= $_;
}
print "$string = $mult\n";


sub place_tiles {
  $tiles_to_place = { map { $_ => 1 } keys %$tiles };
  my $grid_size = scalar(keys %$tiles);

  # pull random tile and put at 20,20 - we'll build from there
  my $random_tile_num = (keys %$tiles)[0];
  $image->[20]->[20] = $random_tile_num;
  delete $tiles_to_place->{$random_tile_num};

  while (scalar(keys %$tiles_to_place)) {
    for my $row (0..40) {
      for my $col (0..40) {
        my $tilenum = $image->[$row]->[$col];
        next unless $tilenum;
        print "Working at $row,$col on tile $tilenum\n" if $verbose;

        my $placed;

        print " What can go above it?\n" if $verbose;
        $placed = match_tile($tilenum,$row,$col,-1, 0,\&tile_top,\&tile_bottom);
        delete $tiles_to_place->{$placed} if $placed;

        print " What can go below it?\n" if $verbose;
        $placed = match_tile($tilenum,$row,$col, 1, 0,\&tile_bottom,\&tile_top);
        delete $tiles_to_place->{$placed} if $placed;

        print " What can go left of it?\n" if $verbose;
        $placed = match_tile($tilenum,$row,$col, 0,-1,\&tile_left,\&tile_right);
        delete $tiles_to_place->{$placed} if $placed;

        print " What can go right of it?\n" if $verbose;
        $placed = match_tile($tilenum,$row,$col, 0, 1,\&tile_right,\&tile_left);
        delete $tiles_to_place->{$placed} if $placed;
      }
    }
  }

  print_image();
  print "\n";
}

sub match_tile {
  my ($tilenum,$row,$col,$add_row,$add_col,$get_match_str,$get_check_str) = @_;

  # skip processing if location already taken
  if ($image->[$row+$add_row]->[$col+$add_col]) {
    print " Skipping because there is already a tile there\n" if $verbose;
    return 0
  }

  my $found = 0;
  for my $check_tile_num (keys %$tiles_to_place) {
    my $rotate_count = 0;
    my $flip_h_count = 0;
    my $flip_v_count = 0;

    while (1) {
      if (check_tile($tilenum,$check_tile_num,$row,$col,$add_row,$add_col,$get_match_str,$get_check_str)) {
        $image->[$row+$add_row]->[$col+$add_col] = $check_tile_num;
        return $check_tile_num;
      }
      
      if ($rotate_count < 4) {
        $rotate_count++;
        rotate_tile($check_tile_num);
        next;
      }
      elsif ($flip_h_count < 1) {
        $flip_h_count++;
        $rotate_count = 0;
        flip_tile_h($check_tile_num);
        next;
      }
      elsif ($flip_v_count < 1) {
        $flip_v_count++;
        $rotate_count = 0;
        flip_tile_v($check_tile_num);
        next;
      }
      else {
        print "$check_tile_num failed\n" if $verbose;
        last;
      }
    }
  }
  return 0
}

sub check_tile {
  my ($match_tilenum,$check_tilenum,$row,$col,$add_row,$add_col,$get_match_str,$get_check_str) = @_;

  my $match_str = $get_match_str->($match_tilenum);
  my $check_str = $get_check_str->($check_tilenum);

  # if it can't even match the first level check, abandon this
  return 0 unless $match_str eq $check_str;

  print "  Initial match found using tile $check_tilenum\n" if $verbose;
  my $inplace_tilenum;

  # ok, how about the other 3 directions?
  # ABOVE the new tile (unless we came from above)
  if ($inplace_tilenum = $image->[$row+$add_row-1]->[$col+$add_col] && $add_row != 1) {
    print "above THAT is already $inplace_tilenum, checking\n" if $verbose;
    return 0 unless tile_top($check_tile_num) eq tile_bottom($inplace_tilenum);
  }
  # BELOW the new tile (unless we came from below)
  if ($inplace_tilenum = $image->[$row+$add_row+1]->[$col+$add_col] && $add_row != -1) {
    print "below THAT is already $inplace_tilenum, checking\n" if $verbose;
    return 0 unless tile_bottom($check_tile_num) eq tile_top($inplace_tilenum);
  }
  # TO THE LEFT OF the new tile (unless we came from the left)
  if ($inplace_tilenum = $image->[$row+$add_row]->[$col+$add_col-1] && $add_col != 1) {
    print "to the left of THAT is already $inplace_tilenum, checking\n" if $verbose;
    return 0 unless tile_left($check_tile_num) eq tile_right($inplace_tilenum);
  }
  # TO THE RIGHT OF the new tile (unless we came from the right)
  if ($inplace_tilenum = $image->[$row+$add_row]->[$col+$add_col+1] && $add_col != -1) {
    print "to the right of THAT is already $inplace_tilenum, checking\n" if $verbose;
    return 0 unless tile_right($check_tile_num) eq tile_left($inplace_tilenum);
  }

  # all directions are either equal or the edges match, looks good!
  print "  Passes ALL checks!\n"  if $verbose;
  return 1;
}

sub rotate_tile {
  my ($tilenum) = @_;

  my $tile = $tiles->{$tilenum};
  my $new_tile = transpose($tile);
  for my $row (0..@$new_tile-1) {
    $new_tile->[$row] = [ reverse @{$new_tile->[$row]} ];
  }
  $tiles->{$tilenum} = $new_tile;
}

sub flip_tile_h {
  my ($tilenum) = @_;

  my $tile = $tiles->{$tilenum};
  my $new_tile;
  for my $row (0..@$tile-1) {
    $new_tile->[$row] = [ reverse @{$tile->[$row]} ];
  }

  $tiles->{$tilenum} = $new_tile;
}

sub flip_tile_v {
  my ($tilenum) = @_;

  rotate_tile($tilenum);
  flip_tile_h($tilenum);
  rotate_tile($tilenum);
  rotate_tile($tilenum);
  rotate_tile($tilenum);
}

sub tile_top {
  my ($tilenum) = @_;

  return 'undef' unless $tilenum && $tiles->{$tilenum};
  return join ('', @{$tiles->{$tilenum}->[0]});
}

sub tile_bottom {
  my ($tilenum) = @_;

  return 'undef' unless $tilenum && $tiles->{$tilenum};
  return join ('', @{$tiles->{$tilenum}->[-1]});
}

sub tile_left {
  my ($tilenum) = @_;

  return 'undef' unless $tilenum && $tiles->{$tilenum};
  my $string = '';
  foreach my $row (@{$tiles->{$tilenum}}) {
    $string .= $row->[0];
  }
  return $string;
}

sub tile_right {
  my ($tilenum) = @_;

  return 'undef' unless $tilenum && $tiles->{$tilenum};
  my $string = '';
  foreach my $row (@{$tiles->{$tilenum}}) {
    $string .= $row->[-1];
  }
  return $string;
}

sub print_image {
  for my $row (0..39) {
    for my $col (0..39) {
      $image->[$row]->[$col]
        ? printf "%04d ", $image->[$row]->[$col]
        : print  "____ ";
    }
    print "\n";
  }
}

sub print_tile {
  my ($tilenum) = @_;

  return unless $tilenum && $tiles->{$tilenum};

  my $tile = $tiles->{$tilenum};
  print "Tile: $tilenum\n";

  for my $row (@$tile) {
    print join(' ', @$row)."\n";
  }
  print "\n";
}

sub find_corners {
  for my $row (0..39) {
    for my $col (0..39) {
      if ($image->[$row]->[$col]) {
        return ($image->[$row]->[$col], $image->[$row]->[$col+11], $image->[$row+11]->[$col], $image->[$row+11]->[$col+11]);
      }
    }
  }
  die "Didn't find corners!?";
}

# Tile 2311:
# ..##.#..#.
# ##..#.....
# #...##..#.
# ####.#...#
# ##.##.###.
# ##...#.###
# .#.#.#..##
# ..#....#..
# ###...#.#.
# ..###..###
#
