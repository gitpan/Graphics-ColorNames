#!/usr/bin/perl

use strict;
use Test::More tests => 1;

require Graphics::ColorNames;
require Graphics::ColourNames;

ok($Graphics::ColorNames::VERSION eq $Graphics::ColourNames::VERSION,
   "Versions match");
