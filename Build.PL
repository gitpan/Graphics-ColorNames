use Module::Build;

my $build = Module::Build->new
    (
     module_name => 'Graphics::ColorNames',
     license => 'perl',
     requires => {
       'perl'                       => '5.6.0',
       'base'                       => 0,
       'AutoLoader'                 => 0,
       'Carp'                       => 0,
       'DirHandle'                  => 0,
       'Exporter'                   => 0,
       'File::Spec'                 => 0,
       'IO::File'                   => 0,
       'Module::Load'               => 0.10,
     },
     recommends => {
       'Test::Pod::Coverage'        => 0,
       'Test::Pod'                  => 1.00,
       'Test::Portability::Files'   => 0,
       'Test::Prereq'               => 0,
     },
     build_requires => {
       'FileHandle'                 => 0,    # for testing
       'Test::More'                 => 0,
     },
     autosplit => [
       'lib/Graphics/ColorNames.pm',
     ],
     create_makefile_pl => 'traditional',
     dist_author        => 'Robert Rothenberg <rrwo at cpan.org>',
     sign               => 0,
);

$build->create_build_script;
