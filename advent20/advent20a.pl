#!/usr/bin/perl -wT

# my one cheat
use Array::Transpose;

our $verbose = 0;

our $tiles;    # 2d tile definitions
our $tilemap;  # 2d tilemap of tilenums placed

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
$mult *= $_ foreach (get_corner_tilemaps());
print "The 4 corners multipled are $mult\n";


sub place_tiles {
  my $tiles_to_place = { map { $_ => 1 } keys %$tiles };
  my $grid_size = scalar(keys %$tiles);

  # pull random tile and put at 20,20 - we'll build from there
  # since we may expand in ANY direction (since we don't KNOW
  # what tilenum is the "center" of the tilemap), but the input
  # is 144 tiles, so 12x12, so starting at 20,20 means it will
  # fit no matter how it grows
  my $random_tile_num = (keys %$tiles)[0];
  $tilemap->[20]->[20] = $random_tile_num;
  delete $tiles_to_place->{$random_tile_num};

  print "\033[2J\033[1;1H\n" if !$verbose;
  while (scalar(keys %$tiles_to_place)) {
    for my $row (0..40) {
      for my $col (0..40) {
        my $tilenum = $tilemap->[$row]->[$col];
        next unless $tilenum;
        print "Working at $row,$col on tile $tilenum\n" if $verbose;

        my $placed;

        # what can go above me
        $placed = match_tile($tilenum,$row,$col,-1, 0,\&tile_top,\&tile_bottom,$tiles_to_place);
        delete $tiles_to_place->{$placed} if $placed;

        # what can go below me
        $placed = match_tile($tilenum,$row,$col, 1, 0,\&tile_bottom,\&tile_top,$tiles_to_place);
        delete $tiles_to_place->{$placed} if $placed;

        # what can go to the left of me
        $placed = match_tile($tilenum,$row,$col, 0,-1,\&tile_left,\&tile_right,$tiles_to_place);
        delete $tiles_to_place->{$placed} if $placed;

        # what can go to the right of me
        $placed = match_tile($tilenum,$row,$col, 0, 1,\&tile_right,\&tile_left,$tiles_to_place);
        delete $tiles_to_place->{$placed} if $placed;
      }
    }
    if (!$verbose) {
      print "\033[1;1H\n";
      print_tilenums();
    }
  }
  # either print finished tilemap (for those watching verbose output)
  # or move to below tilemap we've been showing on screen
  # $verbose ? print_tilenums() : print "\033[15E\n";
  print_tilenums() if $verbose;
}

sub match_tile {
  my ($tilenum,$row,$col,$add_row,$add_col,$get_match_str,$get_check_str,$tiles_to_place) = @_;

  # skip processing if location already taken
  if ($tilemap->[$row+$add_row]->[$col+$add_col]) {
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
        $tilemap->[$row+$add_row]->[$col+$add_col] = $check_tile_num;
        return $check_tile_num;
      }
      
      if ($rotate_count < 4) {
        $rotate_count++;
        rotate_tilenum($check_tile_num);
      }
      elsif ($flip_h_count < 1) {
        $flip_h_count++;
        $rotate_count = 0;
        flip_tilenum_h($check_tile_num);
      }
      elsif ($flip_v_count < 1) {
        $flip_v_count++;
        $rotate_count = 0;
        flip_tilenum_v($check_tile_num);
      }
      else {
        # that's all the things we can try with this $check_tile_num
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
  #
  # ABOVE the new tile (unless we came from above, so we don't need to check again)
  if ($inplace_tilenum = $tilemap->[$row+$add_row-1]->[$col+$add_col] && $add_row != 1) {
    print "above THAT is already $inplace_tilenum, checking\n" if $verbose;
    return 0 unless tile_top($check_tile_num) eq tile_bottom($inplace_tilenum);
  }
  # BELOW the new tile (unless we came from below, so we don't need to check again)
  if ($inplace_tilenum = $tilemap->[$row+$add_row+1]->[$col+$add_col] && $add_row != -1) {
    print "below THAT is already $inplace_tilenum, checking\n" if $verbose;
    return 0 unless tile_bottom($check_tile_num) eq tile_top($inplace_tilenum);
  }
  # TO THE LEFT OF the new tile (unless we came from the left, so we don't need to check again)
  if ($inplace_tilenum = $tilemap->[$row+$add_row]->[$col+$add_col-1] && $add_col != 1) {
    print "to the left of THAT is already $inplace_tilenum, checking\n" if $verbose;
    return 0 unless tile_left($check_tile_num) eq tile_right($inplace_tilenum);
  }
  # TO THE RIGHT OF the new tile (unless we came from the right, so we don't need to check again)
  if ($inplace_tilenum = $tilemap->[$row+$add_row]->[$col+$add_col+1] && $add_col != -1) {
    print "to the right of THAT is already $inplace_tilenum, checking\n" if $verbose;
    return 0 unless tile_right($check_tile_num) eq tile_left($inplace_tilenum);
  }

  # all directions are either equal or the edges match, looks good!
  print "  Passes ALL checks! $check_tilenum is GOOD to place there\n"  if $verbose;
  return 1;
}

sub rotate_tilenum {
  my ($tilenum) = @_;

  my $tile = $tiles->{$tilenum};
  my $new_tile = transpose($tile);
  for my $row (0..@$new_tile-1) {
    $new_tile->[$row] = [ reverse @{$new_tile->[$row]} ];
  }
  $tiles->{$tilenum} = $new_tile;
}

sub flip_tilenum_h {
  my ($tilenum) = @_;

  my $tile = $tiles->{$tilenum};
  my $new_tile;
  for my $row (0..@$tile-1) {
    $new_tile->[$row] = [ reverse @{$tile->[$row]} ];
  }

  $tiles->{$tilenum} = $new_tile;
}

sub flip_tilenum_v {
  my ($tilenum) = @_;

  rotate_tilenum($tilenum);
  flip_tilenum_h($tilenum);
  rotate_tilenum($tilenum);
  rotate_tilenum($tilenum);
  rotate_tilenum($tilenum);
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

# we have a big workspace (40x40), but sample is just 3x3 and 
# input is 12x12, so lets find the corners so we can just print
# the active workspace (or multiply the tilenums there)
sub find_corners {
  my ($min_y, $max_y, $min_x, $max_x) = (40,0,40,0);
  for my $row (0..39) {
    for my $col (0..39) {
      if ($tilemap->[$row]->[$col]) {
        $min_y = $row if $row < $min_y;
        $max_y = $row if $row > $max_y;
        $min_x = $col if $col < $min_x;
        $max_x = $col if $col > $max_x;
      }
    }
  }
  return ($min_y,$max_y,$min_x,$max_x);
}

sub print_tilenums {
  my ($min_y, $max_y, $min_x, $max_x) = find_corners();

  for my $row ($min_y..$max_y) {
    for my $col ($min_x..$max_x) {
      $tilemap->[$row]->[$col]
        ? printf "%04d ", $tilemap->[$row]->[$col]
        : print  "____ ";
    }
    print "\n";
  }
  print "\n";
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

sub get_corner_tilemaps {
  my ($min_y, $max_y, $min_x, $max_x) = find_corners();
  return ($tilemap->[$min_y]->[$min_x], $tilemap->[$min_y]->[$max_x], $tilemap->[$max_y]->[$min_x], $tilemap->[$max_y]->[$max_x]);
}
