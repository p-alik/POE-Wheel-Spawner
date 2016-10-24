Poe-Wheel-Spawner
=================

[![CPAN version](https://badge.fury.io/pl/Plack-Middleware-Dispatch-GP.png)](https://badge.fury.io/pl/Poe-Wheel-Spawner)
[![Build Status](https://travis-ci.org/p-alik/Plack-Middleware-Dispatch-GP.png)](https://travis-ci.org/p-alik/Poe-Wheel-Spawner)
[![Coverage Status](https://coveralls.io/repos/github/p-alik/Plack-Middleware-Dispatch-GP/badge.png)](https://coveralls.io/github/p-alik/Poe-Wheel-Spawner)

Poe::Wheel::Spawner is based on [Poe::Wheel::Run](https://metacpan.org/pod/POE::Wheel::Run). This module offers a smart facility to arrange a minimal required nummer of subprocesses

```perl

    use M43::POE::Wheel::Spawner;
    my $foo = M43::POE::Wheel::Spawner->new(
                pool_size => 2,
                stop_if_done => 1,
                workload => sub { _workload() }
        );

    $foo->run();

    sub _workload {
        # request for a new sibling
        $foo->spawn($$);
        # ...
    }
```
