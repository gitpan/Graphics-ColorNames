package Graphics::ColorNames::HTML;

=head1 NAME

Graphics::ColorNames::HTML - HTML color names and equivalent RGB values

=head1 SYNOPSIS

  require Graphics::ColorNames::HTML;

  $NameTable = Graphics::ColorNames::HTML->NamesRgbTable();
  $RgbBlack  = $NameTable->{black};

=head1 DESCRIPTION

This module defines color names and their associated RGB values from the
HTML 4.0 Specification.

=head1 SEE ALSO

C<Graphics::ColorNames>,  HTML 4.0 Specificiation <http://www.w3.org>

=head1 AUTHOR

Robert Rothenberg <rrwo@cpan.org>

=cut

require 5.005;
use strict;
# use warnings;

use vars qw( $VERSION );

$VERSION = '1.01';

sub NamesRgbTable() {
  use integer;
  return {
    'black'	         => 0x000000,
    'blue'	         => 0x0000ff,
    'aqua'	         => 0x00ffff,
    'lime'	         => 0x00ff00,
    'fuscia'	         => 0xff00ff,
    'red'	         => 0xff0000,
    'yellow'	         => 0xffff00,
    'white'	         => 0xffffff,
    'navy'	         => 0x000080,
    'teal'	         => 0x008080,
    'green'	         => 0x008000,
    'purple'	         => 0x800080,
    'maroon'	         => 0x800000,
    'olive' 	         => 0x808000,
    'gray'	         => 0x808080,
    'silver'	         => 0xc0c0c0,
    };
}

1;

__END__
