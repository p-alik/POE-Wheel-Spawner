Poe-Wheel-Spawner
=================

Poe::Wheel::Run based way to arrange a minimal required nummer of processes


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
