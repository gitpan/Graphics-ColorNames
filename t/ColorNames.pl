use Test;

BEGIN { plan tests => 9, todo => [ ] }

use strict;
use Carp;

use Graphics::ColorNames 0.20, qw( hex2tuple tuple2hex );
ok(1);

tie my %colors, 'Graphics::ColorNames';
ok(1);

my $count = 0;
foreach my $name (keys %colors)
  {
    my @RGB = hex2tuple( $colors{$name} );
    $count++, if (tuple2hex(@RGB) eq $colors{$name} );
  }
ok($count, keys %colors);

$count = 0;
foreach my $name (keys %colors)
  {
    $count++, if ($colors{lc($name)} eq $colors{uc($name)});
  }
ok($count, keys %colors);


$count = 0;
foreach my $name (keys %colors)
  {
    $count++, if (exists($colors{$name}))
  }
ok($count, keys %colors);

eval { undef %colors };
ok(defined($!));

eval { %colors = (); };
ok(defined($!));

eval { $colors{MyCustomColor} = 'FFFFFF'; };
ok(defined($!));

eval { delete($colors{MyCustomColor}); };
ok(defined($!));
