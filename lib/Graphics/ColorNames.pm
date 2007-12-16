package Graphics::ColorNames;
require 5.006;

use strict;
use warnings;

use base 'Exporter';

# use AutoLoader qw( AUTOLOAD );
use Carp;
use Module::Load;

our $VERSION   = '2.01';
$VERSION = eval $VERSION;

our %EXPORT_TAGS = (
 'all'     => [ qw( hex2tuple tuple2hex all_schemes ) ],
 'utility' => [ qw( hex2tuple tuple2hex ) ],
);
our @EXPORT_OK    = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT       = ( );


# We store Schemes in a hash as a quick-and-dirty way to filter
# duplicates (which sometimes occur when fidrectories are repeated
# in @INC or via symlinks).  The order does not matter.

my %FoundSchemes = ( );

my %Names   = ( );
my %Schemes = ( );

sub _load_scheme_from_module {
  my $self   = shift;
  my $scheme = shift;

  my $module = join('::', __PACKAGE__, $scheme);
  eval { load $module; };
  if ($@) {
    $module = $scheme;
    eval { load $module; };
    if ($@) {
      croak "Cannot load color naming scheme \`$scheme\'";
    }
  }
    
  {
    no strict 'refs';
    $self->load_scheme($module->NamesRgbTable);   
  }
}


sub TIEHASH {
  my $class = shift || __PACKAGE__;

  my $count = scalar(keys %Names);
  my $self  = \$count;

  $Names{($self)}   = { };
  $Schemes{($self)} = [ ];

  bless $self, $class;

  if (@_) {
    foreach my $scheme (@_) {
      if (ref $scheme) {
	$self->load_scheme( $scheme );
      }
      elsif (-r $scheme) {
	$self->_load_scheme_from_file( $scheme );
      }
      else {
	$self->_load_scheme_from_module( $scheme );
      }
    }
  } else {
    $self->_load_scheme_from_module('X');
  }

  return $self;
}

sub FETCH {
  my $self   = shift;
  my $key    = lc(shift);

  # If we're passing it an RGB value, return that value

  if ($key =~ m/^\x23?([\da-f]{6})$/i) {
    return $1;
  } else {
    my $value = $Names{($self)}->{$key};
    unless (defined $value) {
      my @schemes = @{ $Schemes{$self} || [] };
      while ((!defined $value) && (my $scheme = shift @schemes)) {
	if ((ref $scheme) eq 'CODE') {
	  $value = &$scheme($key);
	}
	elsif ((ref $scheme) eq 'HASH') {
	  $value = $scheme->{$key};
	}
	else {
	  # This shouldn't be called
	  croak "unsupported scheme type: ", ref($scheme);
	}
      }
    }
    $value = sprintf('%06x', $value ), if (defined $value);
    return $value;
  }
}

sub EXISTS {
  my ($self, $key) = @_;
  defined ($self->FETCH($key));
}

sub FIRSTKEY {
  my $self = shift;
  each %{$Names{($self)}};
}

sub NEXTKEY {
  my $self = shift;
  each %{$Names{($self)}};
}

# Convert 6-digit hexidecimal code (used for HTML etc.) to an array of
# RGB values

sub hex2tuple {
  my $rgb = CORE::hex( shift );
  my ($red, $green, $blue);
  $blue  = ($rgb & 0x0000ff);
  $green = ($rgb & 0x00ff00) >> 8;
  $red   = ($rgb & 0xff0000) >> 16;
  return ($red, $green, $blue);
}


# Convert list of RGB values to 6-digit hexidecimal code (used for HTML, etc.)

sub tuple2hex {
  my ($red, $green, $blue) = @_;
  my $rgb = sprintf "%.2x%.2x%.2x", $red, $green, $blue;
  return $rgb;
}

sub _readonly_error {
  croak "Cannot modify a read-only value";
}

BEGIN {
  no strict 'refs';
  *STORE  = \ &_readonly_error;
  *DELETE = \ &_readonly_error;
  *CLEAR  = \ &_readonly_error; # causes problems with 'undef'

  *new    = \ &TIEHASH;
}

1;

# __END__

sub _find_schemes {

    my $path = shift;

    # BUG: deep-named schemes such as Graphics::ColorNames::Foo::Bar
    # are not supported.

    if (-d $path) {
      my $dh = DirHandle->new( $path )
	|| croak "Unable to access directory $path";
      while (defined(my $fn = $dh->read)) {
	if ((-r File::Spec->catdir($path, $fn)) && ($fn =~ /(.+)\.pm$/)) {
	  $FoundSchemes{$1}++;
	}
      }
    }
  }

sub all_schemes {
    unless (%FoundSchemes) {

      require DirHandle;  # These only need to be loaded once
      require File::Spec;

      foreach my $dir (@INC) {
	_find_schemes(
	  File::Spec->catdir($dir, split(/::/, __PACKAGE__)));
      }
    }
    return (keys %FoundSchemes);
  }

sub _load_scheme_from_file {
  my $self = shift;
  my $file = shift;

  unless (ref $file) {
    unless (-r $file) {
      croak "Cannot load scheme from file: \'$file\'";
    }
    require IO::File;
  }

  my $fh = ref($file) ? $file : (new IO::File);
  unless (ref $file) {
    open($fh, $file)
      || croak "Cannot open file: \'$file\'";
  }

  while (my $line = <$fh>) {
    unless ($line =~ /^[\!\#]/) {
      chomp($line);
      if ($line) {
	my ($red, $green, $blue, $name, $rgb);

	$name  = lc(substr($line, 12));
	$name =~ s/^\s+//;	# remove leading and trailing spaces
	$name =~ s/\s+$//;

	# TODO? Should we add an option to warn if overlapping names
	# are defined? This seems to be too common to be useful.

	unless (defined $Names{($self)}->{$name}) {

	  $red   = eval substr($line,  0, 3);
	  $green = eval substr($line,  4, 3);
	  $blue  = eval substr($line,  8, 3);

	  $rgb   = ($red << 16) | ($green << 8) | ($blue);

          $Names{($self)}->{$name} = $rgb;
	}
      }
    }
  }
  unless (ref $file) {
    close $fh;
  }
}

sub load_scheme {
  my $self   = shift;
  my $scheme = shift;

  if (ref($scheme) eq 'HASH') {
    foreach my $name (keys %$scheme) {
      $Names{($self)}->{lc($name)} = $scheme->{$name},
	unless (defined $Names{($self)}->{lc($name)});
    }
  }
  elsif (ref($scheme) eq 'CODE') {
    push @{ $Schemes{($self)} }, $scheme;
  }
  else {
    undef $!;
    eval {
      if ((ref($scheme) eq 'GLOB') || $scheme->isa('IO::File')
                                   || $scheme->isa('FileHandle')) {
	$self->_load_scheme_from_file($scheme);
      }
    };
    if ($@) {
      croak "unsupported scheme type: ", ref($scheme);
    }
    elsif ($!) {
      croak $!;
    }
  }
}

sub hex {
    my $self = shift;
    my $name = shift;
    my $rgb  = $self->FETCH($name);
    my $pre  = shift;
    unless (defined $pre) { $pre = ""; }
    return ($pre.$rgb);
}

sub rgb {
    my $self = shift;
    my $name = shift;
    my @rgb  = hex2tuple($self->FETCH($name));
    my $sep  = shift || ',';
    return wantarray ? @rgb : join($sep,@rgb);
}

# __END__

=head1 NAME

Graphics::ColorNames - defines RGB values for common color names

=head1 REQUIREMENTS

C<Graphics::ColorNames> should work on Perl 5.6.0.  It requires the
following non-standard modules:

  Module::Load

=head1 SYNOPSIS

  use Graphics::ColorNames qw( hex2tuple tuple2hex );

  tie %ColorTable, 'Graphics::ColorNames', 'X';

  $rgbhex1 = $ColorTable{'green'};    # returns '00ff00'
  $rgbhex2 = tuple2hex( 0, 255, 0 );  # returns '00ff00'
  @rgbtup  = hex2tuple( $rgbhex );    # returns (0, 255, 0)

  $rgbhex3 = $ColorTable{'#123abc'};  # returns '123abc'
  $rgbhex4 = $ColorTable{'123abc'};   # returns '123abc'

=head1 DESCRIPTION

This module defines RGB values for common color names. The intention
is to (1) provide a common module that authors can use with other
modules to specify colors by name; and (2) free module authors from
having to "re-invent the wheel" whenever they decide to give the users
the option of specifying a color by name rather than RGB value.

For example,

  use Graphics::ColorNames 'hex2tuple';
  tie %ColorTable, 'Graphics::ColorNames';

  use GD;

  $img = new GD::Image(100, 100);

  $bgColor = $img->colorAllocate( hex2tuple( $ColorTable{'CadetBlue3'} ) );

Though a little 'bureaucratic', the meaning of this code is clearer:
C<$bgColor> (or background color) is 'CadetBlue3' (which is easier to for one
to understand than C<0x7A, 0xC5, 0xCD>). The variable is named for its
function, not form (ie, C<$CadetBlue3>) so that if the author later changes
the background color, the variable name need not be changed.

As an added feature, a hexidecimal RGB value in the form of #RRGGBB or
RRGGBB will return itself:

  my $rgbhex3 = $ColorTable{'#123abc'};  # returns '123abc'

=head2 Tied Interface

The standard interface (prior to version 0.40) is through a tied hash:

  tie %NameTable, 'Graphics::ColorNames', @SchemeList;

where C<%NameTable> is the tied hash and C<@SchemeList> is a list of
L<color schemes|/Color Schemes>.

A valid color scheme may be the name of a color scheme (such as C<X>
or a full module name such as C<Graphics::ColorNames::X>), a reference
to a color scheme hash or subroutine, or to the path or open
filehandle for a F<rgb.txt> file.

Multiple schemes can be used:

  tie %NameTable, 'Graphics::ColorNames', qw(HTML Netscape);

In this case, if the name is not a valid HTML color, the Netscape name
will be used.

One can load all available schemes (as of version 2.0):

  use Graphics::ColorNames 2.0, 'all_schemes';
  tie %NameTable, 'Graphics::ColorNames', all_schemes();

When multiple color schemes define the same name, then the earlier one
listed has priority (however, hash-based color schemes always have
priority over code-based color schemes).

When no color scheme is specified, the X-Windows scheme is assumed.

Color names are case insensitive.  So "AliceBlue" returns the same
value as "aliceblue", "ALICEBLUE" and "alICEblue".

The value returned is in the six-digit hexidecimal format used in HTML and
CSS (without the initial '#'). To convert it to separate red, green, and
blue values (between 0 and 255), use the L</hex2tuple> function.

=head2 Object-Oriented Interface

If you prefer, an object-oriented interface is available:

  use Graphics::ColorNames 0.40;

  $obj = Graphics::ColorNames->new('/etc/rgb.txt');

  $hex = $obj->hex('skyblue'); # returns "87ceeb"
  @rgb = $obj->rgb('skyblue'); # returns (0x87, 0xce, 0xeb)

The interface is similar to the L<Color::Rgb> module:

=over

=item new

  $obj = Graphics::ColorNames->new( @SCHEMES );

Creates the object, using the default L<color schemes|/Color Schemes>.
If none are specified, it uses the C<X> scheme.

=item load_scheme

  $obj->load_scheme( $scheme );

Loads a scheme dynamically.  The scheme may be any hash or code reference.

=item hex

  $hex = $obj->hex($name, $prefix);

Returns a 6-digit hexidecimal RGB code for the color.  If an optional
prefix is specified, it will prefix the code with that string.  For
example,

  $hex = $obj->hex('blue', '#'); # returns "#0000ff"

=item rgb

  @rgb = $obj->rgb($name);

  $rgb = $obj->rgb($name, $separator);

If called in a list context, returns a triplet.

If called in a scalar context, returns a string separated by an
optional separator (which defauls to a comma).  For example,

  @rgb = $obj->rgb('blue');      # returns (0, 0, 255)

  $rgb = $obj->rgb('blue', ','); # returns "0,0,255"

=back

=head2 Utility Functions

These functions are not exported by default, so much be specified to
be used:

  use Graphics::ColorNames qw( all_schemes hex2tuple tuple2hex );

=over

=item all_schemes

  @schemes = all_schemes();

Returns a list of all available color schemes installed on the machine
in the F<Graphics::ColorNames> namespace.

The order has no significance.

=item hex2tuple

  ($red, $green, $blue) = hex2tuple( $colors{'AliceBlue'});

=item tuple2hex

  $rgb = tuple2hex( $red, $green, $blue );

=back

=head2 Color Schemes

The following schemes are available by default:

=over

=item X

About 750 color names used in X-Windows.

=item HTML

16 common color names defined in the HTML 4.0 specification. These
names are also used with older CSS and SVG specifications. (You may
want to see L<Graphics::ColorNames::SVG> for a complete list.)

=item Netscape

100 color names names associated Netscape 1.1 (I cannot determine whether
they were once usable in Netscape or were arbitrary names for RGB values--
many of these names are not recognized by later versions of Netscape).

This scheme may be deprecated in future versions, but available as a
separate module.

=item Windows

16 commom color names used with Microsoft Windows and related
products.  These are actually the same colors as the L</HTML> scheme,
although with different names.

=back

Rather than a color scheme, the path or open filehandle for a
F<rgb.txt> file may be specified.

Additional color schemes may be available on CPAN.

=head2 Adding Naming Schemes

You can add naming scheme files by creating a Perl module is the name
C<Graphics::ColorNames::SCHEMENAME> which has a subroutine named
C<NamesRgbTable> that returns a hash of color names and RGB values.

The color names must be in all lower-case, and the RGB values must be
24-bit numbers containing the red, green, and blue values in most- significant
to least- significant byte order.

An example naming schema is below:

  package Graphics::ColorNames::Metallic;

  sub NamesRgbTable() {
    use integer;
    return {
      copper => 0xb87333,
      gold   => 0xcd7f32,
      silver => 0xe6e8fa,
    };
  }

You would use the above schema as follows:

  tie %colors, 'Graphics::ColorNames', 'Metallic';

An example of an additional module is the L<Graphics::ColorNames::Mozilla>
module by Steve Pomeroy.

Since version 1.03, C<NamesRgbTable> may also return a code reference:

  package Graphics::ColorNames::Orange;

  sub NamesRgbTable() {
    return sub {
      my $name = shift;
      return 0xffa500;        
    };
  }

See L<Graphics::ColorNames::GrayScale> for an example.

Note that extentions of the form "Graphics::ColourNames::*" are not
supported at this time, although full scheme module names can be
specified:

  tie %NameTable, 'Graphics::ColourNames', 'Graphics::ColourNames::Scheme';

=head1 SEE ALSO

L<Color::Rgb> has a similar function to this module, but parses an
F<rgb.txt> file.

L<Graphics::ColorObject> can convert between RGB and other color space
types.

=head1 AUTHOR

Robert Rothenberg <rrwo at cpan.org>

=head2 Acknowledgements

Alan D. Salewski <alans at cji.com> for feedback and the addition of
C<tuple2hex>.

Steve Pomeroy <xavier at cpan.org> for pointing out invalid color
definitions in X color space.

<chemboy at perlmonk.org> who pointed out a mispelling of "fuchsia" in
the HTML color space L<http://rt.cpan.org/Ticket/Display.html?id=1704>.

<magnus at mbox604.swipnet.se> who pointed out mispellings and naming
inconsistencies.

=head2 Suggestions and Bug Reporting

Feedback is always welcome.  Please use the CPAN Request Tracker at
L<http://rt.cpan.org> to submit bug reports.

There is now a SourceForge project for this package at
L<http://sourceforge.net/projects/colornames/>

If you create additional color schemes, please make them available
separately in CPAN rather than submit them to me for inclusion into
this module.

=head1 LICENSE

Copyright (c) 2001-2007 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
