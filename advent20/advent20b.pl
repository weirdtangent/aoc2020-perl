#!/usr/bin/perl -wT

use Array::Transpose;

our $verbose = 0;

our $tiles;
our $tiles_to_place;
our $image;
our $photo;
our @corners;

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
print_tilenums();
remove_borders();
construct_photo();
print_photo();
find_seamonster();

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

sub rotate_photo {
  my $new_photo = transpose($photo);
  for my $row (0..@$new_photo-1) {
    $new_photo->[$row] = [ reverse @{$new_photo->[$row]} ];
  }
  $photo = $new_photo;
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

sub flip_photo_h {
  my $new_photo;
  for my $row (0..@$photo-1) {
    $new_photo->[$row] = [ reverse @{$photo->[$row]} ];
  }
  $photo = $new_photo;
}

sub flip_tile_v {
  my ($tilenum) = @_;

  rotate_tile($tilenum);
  flip_tile_h($tilenum);
  rotate_tile($tilenum);
  rotate_tile($tilenum);
  rotate_tile($tilenum);
}

sub flip_photo_v {
  rotate_photo();
  flip_photo_h();
  rotate_photo();
  rotate_photo();
  rotate_photo();
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

sub print_tilenums {
  for my $row (9..31) {
    for my $col (9..31) {
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
        push @corners, [ $row, $col ];
        push @corners, [ $row+11, $col ];
        push @corners, [ $row, $col+11 ];
        push @corners, [ $row+11, $col+11 ];
        return ($image->[$row]->[$col], $image->[$row]->[$col+11], $image->[$row+11]->[$col], $image->[$row+11]->[$col+11]);
      }
    }
  }
  die "Didn't find corners!?";
}

sub remove_borders {
  foreach my $tilenum (keys %$tiles) {
    print "remove borders from $tilenum\n" if $verbose;
    my $newtile;
    my $tile = $tiles->{$tilenum};
    for my $row (1..(@$tile-2)) {
      for my $col (1..(@{$tile->[$row]}-2)) {
        $newtile->[$row-1]->[$col-1] = $tile->[$row]->[$col];
      }
    }                                      
    $tiles->{$tilenum} = $newtile;
  }
}

sub construct_photo {
  my $photo_row=0;
  for my $row (0..39) {
    for my $tilerow(0..7) {
      my $tile_count = 0;
      for my $col (0..39) {
        my $tilenum = $image->[$row]->[$col];
        next unless $tilenum;
        $tile_count++;
        my $tile = $tiles->{$tilenum};
        push @{$photo->[$photo_row]}, @{$tile->[$tilerow]};
      }
      $photo_row++ if $tile_count;
    }
  }
}

sub print_photo {
  for my $row (0..@$photo-1) {
    print join('', @{$photo->[$row]})."\n";
  }
}

sub find_seamonster {
  while (1) { 
    my $rotate_count = 0;
    my $flip_h_count = 0;
    my $flip_v_count = 0;

    my $monster_count = 0;
    while (!$monster_count) {
      $monster_count = check_for_monsters();
      if ($monster_count) {
        print "Found $monster_count sea monsters in photo!\n";
        print rough_waters($monster_count)." rough water count\n";
        print_photo();
        return 1;
      }
      
      if ($rotate_count < 4) {
        $rotate_count++;
        rotate_photo();
        next;
      }
      elsif ($flip_h_count < 1) {
        $flip_h_count++;
        $rotate_count = 0;
        flip_photo_h();
        next;
      }
      elsif ($flip_v_count < 1) {
        $flip_v_count++;
        $rotate_count = 0;
        flip_photo_v();
        next;
      }
      else {
        die "find_seamonster failed\n";
      }
    }
  }
}

sub check_for_monsters {
  my $monster_string = "                  # \n"
                      ."#    ##    ##    ###\n"
                      ." #  #  #  #  #  #   \n";

  my $monster;
  my $row = 0;
  foreach my $string (split "\n", $monster_string) {
    push @{$monster->[$row++]}, split '', $string;
  }

  my $count = 0;

  my $monster_height = @$monster;
  my $monster_width = @{$monster->[0]};

  for my $row (0..(@$photo-$monster_height)) {
    for my $col (0..(@{$photo->[$row]}-$monster_width)) {
      my $snippet;
      my $snippet_row = 0;
      for my $y (0..$monster_height-1) {
        for my $x (0..$monster_width-1) {
          $snippet->[$snippet_row]->[$x] = $photo->[$row+$y]->[$col+$x];
        }
        $snippet_row++;
      }

      if (and_arrays($monster, $snippet)) {
        $count++;
        reveal_seamonster($row, $col, $monster);
      }
    }
  }
  return $count;
}

sub and_arrays {
  my ($a1, $a2) = @_;

  my $should_match = 0;
  my $does_match = 0;

  die "Array heights don't match? ".scalar(@$a1).' vs '.scalar(@$a2)
    unless (scalar(@$a1) == scalar(@$a2));

  for $y (0..@$a1-1) {
    for $x (0..@{$a1->[$y]}-1) {
      die "Array widths don't match? ".scalar(@{$a1->[$y]}).' vs '.scalar(@{$a2->[$y]})
        unless (scalar(@{$a1->[$y]}) == scalar(@{$a2->[$y]}));
      $should_match++ if $a1->[$y]->[$x] eq '#';
      $does_match++   if $a1->[$y]->[$x] eq '#' && $a2->[$y]->[$x] eq '#';
    }
  }
  print "valid AND of two arrays, should_match = $should_match, does_match = $does_match\n" if $verbose;

  return $does_match == $should_match;
}

sub reveal_seamonster {
  my ($row, $col, $monster) = @_;

  my $monster_height = @$monster;
  my $monster_width = @{$monster->[0]};

  print "Revealing sea monster at $row,$col at size $monster_height x $monster_width\n" if $verbose;
  for my $y (0..$monster_height-1) {
    for my $x (0..$monster_width-1) {
      $photo->[$row+$y]->[$col+$x] = "\033[1mO\033[0m" if $monster->[$y]->[$x] eq '#';
    }
  }
}

sub rough_waters {
  my ($monster_count) = @_;

  my $rough_water_count = 0;
  for my $row (0..39) {
    for my $tilerow(0..7) {
      for my $col (0..39) {
        my $tilenum = $image->[$row]->[$col];
        next unless $tilenum;
        my $tile = $tiles->{$tilenum};
        $rough_water_count += grep /#/, @{$tile->[$tilerow]}
      }
    }
  }

  $rough_water_count -= ($monster_count * 15);
  return $rough_water_count;
}
