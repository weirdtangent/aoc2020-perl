#!/usr/bin/perl -wT

use List::Util qw(max min);
use Array::Utils qw(array_diff);

my $verbose = 0;

my $cards;
my $version;
my $winner;
my $round = 1;

while(my $line = <STDIN>) {
  chomp $line;
  if ($line =~ /Player (\d):/) {
    $player = $1;
  }
  elsif ($line =~ /(^\d+)/) {
    push @{$cards->{$player}}, $1;
  }
}

# play rounds until someone runs out of cards OR duplicate decks indicate recursion and player 1 wins
while (!$winner && scalar(@{$cards->{1}}) && scalar(@{$cards->{2}})) {
  my $round_winner;
  $version->{1}->{$round} = [ @{$cards->{1}} ];
  $version->{2}->{$round} = [ @{$cards->{2}} ];

  if ($round > 1) {
    for my $check_round (1..$round-1) {
      if (!array_diff(@{$version->{1}->{$check_round}}, @{$cards->{1}}) && !array_diff(@{$version->{2}->{$check_round}}, @{$cards->{2}})) {
        print "Duplicate hands detected! Player 1 wins round!\n" if $verbose;
        $winner = 1;
        last;
      }
    }
  }
  unless ($winner) {
    $round++;
    print "Player 1 cards: ".join(', ', @{$cards->{1}})."\n" if $verbose;
    print "Player 2 cards: ".join(', ', @{$cards->{2}})."\n" if $verbose;

    my $player1_card = shift @{$cards->{1}};
    my $player2_card = shift @{$cards->{2}};
    print "  $player1_card vs $player2_card\n" if $verbose;
    if (scalar(@{$cards->{1}}) >= $player1_card && scalar(@{$cards->{2}}) >= $player2_card) {
      print "Round $round: Recursive game!\n" if $verbose;
      $round_winner = recursive_game($player1_card, $player2_card);
    }
    else {
      print "Round $round: Normal round\n" if $verbose;
      $round_winner = $player1_card > $player2_card ? 1 : 2;
    }
    push @{$cards->{$round_winner}}, $round_winner == 1 ? $player1_card : $player2_card;
    push @{$cards->{$round_winner}}, $round_winner == 1 ? $player2_card : $player1_card;
  }
}

$winner ||= scalar(@{$cards->{1}}) ? 1 : 2;
my $score = 0;
my $mult = 1;
while (my $card = pop @{$cards->{$winner}}) {
  $score += ($card * $mult++);
}

print "Score: $score\n";

sub recursive_game {
  my ($player1_card, $player2_card) = @_;

  my $copy;
  my $version;
  my $winner;
  my $subround = 1;

  # start with a copy of cards from deck, with num cards equal to card drawn 
  $copy->{1} = [ @{$cards->{1}}[0..$player1_card-1] ];
  $copy->{2} = [ @{$cards->{2}}[0..$player2_card-1] ];

  while (!$winner && scalar(@{$copy->{1}}) && scalar(@{$copy->{2}})) {
    print "Player 1 copy_cards: ".join(', ', @{$copy->{1}})."\n" if $verbose;
    print "Player 2 copy_cards: ".join(', ', @{$copy->{2}})."\n" if $verbose;
    print "Sub-round $subround: Recursive round!\n" if $verbose;

    $version->{1}->{$subround} = [ @{$copy->{1}} ];
    $version->{2}->{$subround} = [ @{$copy->{2}} ];

    if ($subround > 1) {
      for my $check_round (1..$subround-1) {
        if (!array_diff(@{$version->{1}->{$check_round}}, @{$copy->{1}}) && !array_diff(@{$version->{2}->{$check_round}}, @{$copy->{2}})) {
          print "Duplicate hands detected! Player 1 wins round!\n" if $verbose;
          $winner = 1;
          last;
        }
      }
    }
    unless ($winner) {
      $subround++;
      my $player1_card = shift @{$copy->{1}};
      my $player2_card = shift @{$copy->{2}};
      print "  $player1_card vs $player2_card\n" if $verbose;
      my $round_winner = $player1_card > $player2_card ? 1 : 2;
      push @{$copy->{$round_winner}}, max $player1_card, $player2_card;
      push @{$copy->{$round_winner}}, min $player1_card, $player2_card;
    }
  }

  $winner ||= scalar(@{$copy->{1}}) ? 1 : 2;
  return $winner;
}
