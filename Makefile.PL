# Makefile.PL for Graphics-ColorNames package
# $Id: Makefile.pl,v 0.22 2001/04/15 13:39:31 rob Exp rob $

use ExtUtils::MakeMaker;

WriteMakefile(
    'PM' => {
       'ColorNames.pm'  => '$(INST_LIBDIR)/ColorNames.pm',
       'X.pm'           => '$(INST_LIBDIR)/ColorNames/X.pm',
       'HTML.pm'        => '$(INST_LIBDIR)/ColorNames/HTML.pm',
       'Windows.pm'     => '$(INST_LIBDIR)/ColorNames/Windows.pm',
    },
    'NAME'		=> 'Graphics::ColorNames',
    'VERSION_FROM'	=> 'ColorNames.pm',
    'PREREQ_PM'		=> {},
  ($] ge '5.005') ? (
    'AUTHOR'   => 'Robert Rothenberg (rrwo@cpan.org)',
    'ABSTRACT' => 'RGB values for standard color names',
  ) : (),
);
