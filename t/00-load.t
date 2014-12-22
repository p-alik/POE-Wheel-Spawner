use 5.006;
use strict;
use warnings FATAL   => 'all';
use Test::More tests => 1;

BEGIN {
    use_ok('Poe::Wheel::Spawner') || print "Bail out!\n";
}

diag("Testing Poe::Wheel::Spawner $Poe::Wheel::Spawner::VERSION, Perl $], $^X");
