use Module::Build;

my $build = Module::Build->new
    (
     module_name => 'Graphics::ColorNames',
     license => 'perl',
     requires => {
       'perl'                       => '5.005',
       'Carp'                       => 0,
     },
     recommends => {
     },
     build_requires => {
       'Test::More'                 => 0,
     },
     create_makefile_pl => 'traditional',
     dist_author        => 'Robert Rothenberg <rrwo at cpan.org>',
);

$build->create_build_script;
