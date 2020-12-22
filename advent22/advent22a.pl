#!/usr/bin/perl -wT

use List::Util qw(max min);

my $cards;

while(my $line = <STDIN>) {
  chomp $line;
  if ($line =~ /Player (\d):/) {
    $player = $1;
  }
  elsif ($line =~ /(^\d+)/) {
    push @{$cards->{$player}}, $1;
  }
}

# play rounds until someone runs out of cards
while (scalar(@{$cards->{1}}) && scalar(@{$cards->{2}})) {
  my $player1_card = shift @{$cards->{1}};
  my $player2_card = shift @{$cards->{2}};
  my $winner = $player1_card > $player2_card ? 1 : 2;
  push @{$cards->{$winner}}, max $player1_card, $player2_card;
  push @{$cards->{$winner}}, min $player1_card, $player2_card;
}

my $winner = scalar(@{$cards->{1}}) ? 1 : 2;
my $score = 0;
my $mult = 1;
while (my $card = pop @{$cards->{$winner}}) {
  $score += ($card * $mult++);
}

print "Score: $score\n";
