#!/usr/bin/perl

use strict;
use Test::More;

if (eval "use Test::Pod::Coverage tests => 1") {
}
else {
  plan skip_all => "Test::Pod::Coverage required" if $@;
}

pod_coverage_ok("Graphics::ColorNames");


