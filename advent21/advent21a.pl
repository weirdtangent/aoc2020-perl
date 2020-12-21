#!/usr/bin/perl -wT

use Data::Dumper;
use List::Util qw(all none reduce);

our $verbose = 0;

our $ingredient;
our $allergen;
our $item;
our $icount;

my $itemcount=1000;
while(my $line = <STDIN>) {
  chomp $line;

  my @section = split /[\(\)]/, $line;
  my @i = split /\s+/, $section[0];
  $section[1] =~ s/^contains //;
  my @a = split /,\s+/, $section[1];

  $item->{$itemcount++} = {
    ingredient => { map { $_ => 1 } @i},
    allergen => { map { $_ => 1 } @a},
  };

  foreach my $i (@i) {
    $icount->{$i}++;
    foreach my $a (@a) {
      $ingredient->{$i}->{$a} = 1;
      $allergen->{$a}->{$i} = 1;
    }
  }
}

clean_list();
non_allergens();
list_ingredients();

sub ingredients {
  print "\nIngredients:\n";
  foreach my $i (sort keys %$ingredient) {
    print "$i may contain ".join(', ', keys %{$ingredient->{$i}})."\n";
  }
}

sub clean_list {
  my $activity;

  do {
    $activity = 0;

    for my $itemnum (keys %$item) {
      for my $i (keys %{$item->{$itemnum}->{ingredient}}) {
        for my $a (keys %{$item->{$itemnum}->{allergen}}) {
          for my $looknum (keys %$item) {
            next unless exists $item->{$looknum}->{allergen}->{$a};
            if (!exists $item->{$looknum}->{ingredient}->{$i} && (exists $ingredient->{$i}->{$a} || exists $allergen->{$a}->{$i})) {
              delete $ingredient->{$i}->{$a};
              delete $allergen->{$a}->{$i};
              $activity++;
            }
          }
        }
      }
    }
  } while $activity;

  do {
    $activity = 0;

    for my $i (keys %$ingredient) {
      if (keys %{$ingredient->{$i}} == 1) {
        my $a = (keys %{$ingredient->{$i}})[0];
        for my $id (keys %$ingredient) {
          next if $i eq $id;
          if (exists $ingredient->{$id}->{$a}) {
            delete $ingredient->{$id}->{$a};
            delete $allergen->{$a}->{$id};
            $activity++;
          }
        }
      }
    }
  } while $activity;
}

sub non_allergens {
  my $total = 0;

  foreach my $i (sort keys %$ingredient) {
    next if keys %{$ingredient->{$i}};
    $total += $icount->{$i};
  }
  print "$total ingredients contain no allergens\n\n";
}

sub list_ingredients {
  print "Ingredients without allergens:\n";

  my $final;

  foreach my $i (sort keys %$ingredient) {
    next unless keys %{$ingredient->{$i}};
    $final->{(keys %{$ingredient->{$i}})[0]} = $i;
  }

  my $output='';
  foreach my $a (sort keys %$final) {
    $output .= ($output ? ',' : '') . $final->{$a};
  }
  print $output."\n";
}
