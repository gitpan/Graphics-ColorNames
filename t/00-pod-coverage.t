#!/usr/bin/perl

use strict;
use Test::More tests => 1;

eval "use Test::Pod::Coverage";

plan skip_all => "Test::Pod::Coverage required" if $@;

pod_coverage_ok("Graphics::ColorNames");

