#!/usr/bin/perl

use strict;
use Test::More tests => 4;

require Graphics::ColorNames;

my @Modules = (qw( X HTML Windows Netscape));

require Graphics::ColourNames;

foreach my $mod (@Modules) {
    use_ok("Graphics::ColorNames::$mod", $Graphics::ColorNames::VERSION);
}
