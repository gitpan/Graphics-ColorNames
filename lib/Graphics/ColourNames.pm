package Graphics::ColourNames;

require 5.006;

use strict;
use warnings;

use base 'Graphics::ColorNames';

our $VERSION = '2.0_04';
$VERSION = eval $VERSION;

our @EXPORT    = qw( );
our @EXPORT_OK = qw( hex2tuple tuple2hex all_schemes );

BEGIN {
  foreach my $func (qw(hex2tuple tuple2hex all_schemes)) {
    no strict 'refs';
    *$func = sub {
     goto "Graphics::ColorNames::$func";
    };
  }
}


1;

__END__

=head1 NAME

Graphics::ColourNames - alias for Graphics::ColorNames

=head1 SYNOPSIS

  use Graphics::ColourNames qw( hex2tuple tuple2hex );

  tie %NameTable, 'Graphics::ColourNames', 'X';

  my $rgbhex1 = $NameTable{'green'};    # returns '00ff00'
  my $rgbhex2 = tuple2hex( 0, 255, 0 ); # returns '00ff00'
  my @rgbtup  = hex2tuple( $rgbhex );   # returns (0, 255, 0)

  my $rgbhex3 = $NameTable{'#123abc'};  # returns '123abc'
  my $rgbhex4 = $NameTable{'123abc'};   # returns '123abc'

=head1 DESCRIPTION

This module is an alias for L<Graphics::ColorNames>, using the British
style of spelling.

It does not alter the spelling of individual colour names in colour
schemas.

=head1 AUTHOR

Robert Rothenberg <rrwo at cpan.org>

=head1 LICENSE

Copyright (c) 2004-2006 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

