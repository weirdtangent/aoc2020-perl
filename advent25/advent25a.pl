#!/usr/bin/perl -wT

my $verbose = 0;

my $value = 7;
my $modval = 20201227;

my $card_loop_size = 0;
my $door_loop_size = 0;

my $pubkey1 = <STDIN>;
chomp $pubkey1;

my $pubkey2 = <STDIN>;
chomp $pubkey2;


# find card loop size
my $card_value = 1;
my $card_subject = 7;
do {
  $card_value *= $card_subject;
  $card_value %= $modval;
  $card_loop_size++;
} while ($card_value != $pubkey1);

print "card loop size of $card_loop_size gave us $pubkey1\n" ;

# find door loop size
my $door_value = 1;
my $door_subject = 7;
do {
  $door_value *= $door_subject;
  $door_value %= $modval;
  $door_loop_size++;
} while ($door_value != $pubkey2);

print "door loop size of $door_loop_size gave us $pubkey2\n" ;

# try transforming card public key
my $card_pub_value = 1;
for (1..$card_loop_size) {
  $card_pub_value *= $pubkey2;
  $card_pub_value %= $modval;
}
print "card public key = $card_pub_value\n";

# try transforming door public key
my $door_pub_value = 1;
for (1..$door_loop_size) {
  $door_pub_value *= $pubkey1;
  $door_pub_value %= $modval;
}
print "door public key = $door_pub_value\n";

