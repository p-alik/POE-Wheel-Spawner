POE-Wheel-Spawner
=================

[![CPAN version](https://badge.fury.io/pl/POE-Wheel-Spawner.png)](https://badge.fury.io/pl/POE-Wheel-Spawner)
[![Build Status](https://travis-ci.org/p-alik/POE-Wheel-Spawner.png)](https://travis-ci.org/p-alik/POE-Wheel-Spawner)
[![Coverage Status](https://coveralls.io/repos/github/p-alik/POE-Wheel-Spawner/badge.png)](https://coveralls.io/github/p-alik/POE-Wheel-Spawner)

POE::Wheel::Spawner is based on [POE::Wheel::Run](https://metacpan.org/pod/POE::Wheel::Run). This module offers a smart facility to arrange a minimal required nummer of subprocesses

```perl

    use POE::Wheel::Spawner;
    my $foo = POE::Wheel::Spawner->new(
                pool_size => 2,
                stop_if_done => 1,
                workload => sub { _workload() }
        );

    $foo->run();

    sub _workload {
        # request for a new sibling
        $foo->spawn($$);
        # do some stuff
    }
```
