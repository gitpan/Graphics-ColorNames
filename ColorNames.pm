package Graphics::ColorNames;

require 5.005;

use strict;
# use warnings;

use vars qw( @ISA $VERSION @EXPORT @EXPORT_OK );

use Carp;

@ISA = qw( Exporter );

$VERSION   = '0.21';

@EXPORT    = qw( );
@EXPORT_OK = qw( hex2tuple tuple2hex );

sub TIEHASH
  {
    my $class = shift;

    my $self  = {
      SCHEMES => [ ], # a list of naming schemes, in priority search order
    };

    # To-do: eventually use "foreach my $scheme (@_)"
    my $scheme = shift || 'X';
    {
	my $module = "Graphics\:\:ColorNames\:\:$scheme";
	eval "require $module;";
	if ($@)
	  {
	    croak "Cannot load color naming scheme \`$scheme\'";
	  }
	else
	  {
	    no strict 'refs';
	    push @{ $self->{SCHEMES} }, $module->NamesRgbTable();

	  }

      }

    if (shift)
      {
	croak "Cannot handle multiple color naming schemes";
      }

    bless $self, $class;
  }

sub FETCH
  {
    my ($self, $key) = @_;
    sprintf( '%06x', $self->{SCHEMES}->[0]->{ lc($key) } );
  }

sub EXISTS
  {
    my ($self, $key) = @_;
    exists( $self->{SCHEMES}->[0]->{ lc($key) } );
  }

sub FIRSTKEY
  {
    my $self = shift;
    my $a = keys %{$self->{SCHEMES}->[0]};
    each %{$self->{SCHEMES}->[0]};
  }

sub NEXTKEY
  {
    my $self = shift;
    each %{$self->{SCHEMES}->[0]};
  }

sub hex2tuple

# Convert 6-digit hexidecimal code (used for HTML etc.) to an array of
# RGB values

  {
    my $rgb = hex( shift );
    my ($red, $green, $blue);
    $blue  = ($rgb & 0x0000ff);
    $green = ($rgb & 0x00ff00) >> 8;
    $red   = ($rgb & 0xff0000) >> 16;
    return ($red, $green, $blue);
  }

sub tuple2hex

# Convert list of RGB values to 6-digit hexidecimal code (used for HTML, etc.)
  {
    my ($red, $green, $blue) = @_;
    my $rgb = sprintf "%.2x%.2x%.2x", $red, $green, $blue;
    return $rgb;
  }

sub _readonly_error
  {
    croak "Cannot modify a read-only value";
  }

BEGIN
  {
    no strict 'refs';
    *STORE  = \ &_readonly_error;
    *DELETE = \ &_readonly_error;
    *CLEAR  = \ &_readonly_error; # causes problems with 'undef'
  }

1;

__END__

=head1 NAME

Graphics::ColorNames - defines RGB values for common color names

=head1 REQUIREMENTS

C<Graphics::ColorNames> should work on Perl 5.005.

It uses only standard modules.

=head2 Installation

Installation is pretty standard:

  perl Makefile.PL
  make
  make test
  make install

=head1 SYNOPSIS

  use Graphics::ColorNames qw( hex2tuple tuple2hex );

  tie %NameTable, 'Graphics::ColorNames', 'X';

  my $rgbhex = $NameTable{'green'};    # returns '00ff00'
  my $rgbhex = tuple2hex( 0, 255, 0 )  # returns '00ff00'
  my @rgbtup = hex2tuple( $rgbhex );   # returns (0, 255, 0)

=head1 DESCRIPTION

This module defines RGB values for common color names. The intention is to
(1) provide a common module that authors can use with other modules to
specify colors; and (2) free module authors from having to "re-invent the
wheel" whenever they decide to give the users the option of specifying a
color by name rather than RGB value.

For example,

  use Graphics::ColorNames 'hex2tuple';
  tie %COLORS, 'Graphics::ColorNames';

  use GD;

  $img = new GD::Image(100, 100);

  $bgColor = $img->colorAllocate( hex2tuple( $COLORS{'CadetBlue3'} ) );

Though a little 'bureaucratic', the meaning of this code is clearer:
C<$bgColor> (or background color) is 'CadetBlue3' (which is easier to for one
to understand than C<0x7A, 0xC5, 0xCD>). The variable is named for its
function, not form (ie, C<$CadetBlue3>) so that if the author later changes
the background color, the variable name need not be changed.

=head2 Usage

The interface is through a tied hash:

  tie %NAMETABLE, 'Graphics::ColorNames', SCHEME

where C<%NAMETABLE> is the tied hash and C<SCHEME> is the color scheme.
Currently three schemes are available:

=over

=item X

550 color names used in X-Windows. I<This is the default naming scheme>, since
it provides the most names.

=item HTML

16 common color names defined in the HTML 4.0 specification. These names
are also used with CSS and SVG.

=item Windows

16 commom color names used with Microsoft Windows and related products.
These are actually the same colors as C<HTML>, although with different
names.

=back

RGB values can be retrieved with a case-insensitive hash key:

  $rgb = $colors{'AliceBlue'};

The value returned is in the six-digit hexidecimal format used in HTML and
CSS (without the initial '#'). To convert it to separate red, green, and
blue values (between 0 and 255), use the C<hex2tuple> function:

  @rgb = hex2tuple( $colors{'AliceBlue'} );

or

  ($red, $green, $blue) = hex2tuple( $colors{'AliceBlue'});

To convert separated red, green, and blue values into the corresponding RGB
hexidecimal format, use the C<tuple2hex> function:

  $rgb = tuple2hex( $red, $green, $blue );

The C<hex2tuple> and C<tuple2hex> functions are not exported by default. You
must specify them explicitly when you 'use' the module.

=head1 CAVEAT

This module is experimental. The interface may change.

=head1 AUTHOR

Robert Rothenberg <rrwo@cpan.org>

=head1 CONTRIBUTORS

Alan D. Salewski <alans@cji.com> for feedback and the addition of
C<tuple2hex>.

=head1 LICENSE

Copyright (c) 2001 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
