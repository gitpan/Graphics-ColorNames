#!/usr/bin/perl

use strict;

use Test::More tests => 7;

use_ok('Graphics::ColorNames', 1.06, qw( hex2tuple tuple2hex ));

tie my %colors, 'Graphics::ColorNames', 'Netscape';
ok(tied %colors);

ok(keys %colors == 100); #

my $count = 0;
foreach my $name (keys %colors)
  {
    my @RGB = hex2tuple( $colors{$name} );
    $count++, if (tuple2hex(@RGB) eq $colors{$name} );
  }
ok($count == keys %colors);

# Problem is with Netscape's color definitions

{
  local $TODO = "Problem with Netscape color definitions";
  ok($colors{gold}      ne $colors{mediumblue});
  ok($colors{lightblue} ne $colors{mediumblue});
  ok($colors{lightblue} ne $colors{gold});
}
