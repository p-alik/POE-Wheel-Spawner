use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

my $n = 'POE::Wheel::Spawner';
use_ok($n) || print "Bail out!\n";

can_ok $n, qw/
    run
    _handle_start
    _handle_start
    _handle_sig_child
    _handle_done
    _handle_stderr
    _handle_stdout
    /;

my $cls = new_ok(
    $n,
    [
        pool_size    => 3,
        stop_if_done => 1,
        workload     => sub { _workload() }
    ]
);

subtest 'run' => sub {
    ok($cls->run(debug => 0, trace => 0) || 1, 'run ...');
    is $cls->{_workers_sig_count}, $cls->{pool_size},
        '_workers_sig_count = pool_size';
};

done_testing();

sub _workload {
    ok $cls->spawn($$), "spawn($$)";
    my $sleep = int(rand(5) + 1);
    sleep($sleep);

    pass "$$ do some job in $sleep seconds";
} ## end sub _workload
