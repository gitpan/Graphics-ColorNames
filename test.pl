use Test;

BEGIN { plan tests => 4, todo => [ 3 ] }

use strict;
use Carp;

use Graphics::ColorNames qw( hex2tuple );
ok(1);

tie my %colors, 'Graphics::ColorNames', qw( HTML );
ok(1);

ok(keys %colors, 16);

my $count = 0;
foreach my $name (keys %colors)
  {
#     print STDERR $name, "\n";
    my @RGB = hex2tuple( $colors{$name} );
    $count++, if (sprintf('%02x%02x%02x', @RGB) eq $colors{$name} );
  }
ok($count, keys %colors);
