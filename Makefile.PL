# Makefile.PL for Graphics-ColorNames package
# $Id$

use ExtUtils::MakeMaker;

WriteMakefile(
    'PM' => {
       'ColorNames.pm'  => '$(INST_LIBDIR)/ColorNames.pm',
       'X.pm'           => '$(INST_LIBDIR)/ColorNames/X/X.pm',
       'HTML.pm'        => '$(INST_LIBDIR)/ColorNames/HTML/HTML.pm',
       'Windows.pm'     => '$(INST_LIBDIR)/ColorNames/Windows/Windows.pm',
    },
    'NAME'		=> 'Graphics::ColorNames',
    'VERSION_FROM'	=> 'ColorNames.pm',
    'PREREQ_PM'		=> {},
  ($] ge '5.005') ? (
    'AUTHOR'   => 'Robert Rothenberg (rrwo@cpan.org)',
    'ABSTRACT' => 'RGB values for standard color names',
  ) : (),
);
