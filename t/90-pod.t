#!/usr/bin/perl

use strict;
use Test::More;

plan skip_all => "Enable DEVEL_TESTS environent variable"
  unless ($ENV{DEVEL_TESTS});

eval "use Test::Pod 1.00";

plan skip_all => "Test::Pod 1.00 required" if $@;

my @poddirs = qw( blib  );

all_pod_files_ok( all_pod_files( @poddirs ) );
