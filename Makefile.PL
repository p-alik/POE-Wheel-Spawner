use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Poe::Wheel::Spawner',
    AUTHOR           => q{Alexei Pastuchov E<lt>palik at cpan.orgE<gt>.},
    VERSION_FROM     => 'lib/Poe/Wheel/Spawner.pm',
    ABSTRACT_FROM    => 'lib/Poe/Wheel/Spawner.pm',
    LICENSE          => 'perl',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        #'ABC'              => 1.6,
        #'Foo::Bar::Module' => 5.0401,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Poe-Wheel-Spawner-*' },
);
