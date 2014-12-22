package Poe::Wheel::Spawner;

use 5.006;
use strict;
use warnings;

use fields qw/
    pool_size
    stop_if_done
    workload
    _workers_sig_count
    /;

use POE qw/Wheel::Run Filter::Reference/;

=head1 NAME

Poe::Wheel::Spawner

=head1 DESCRIPTION

Poe::Wheel::Spawner generate only one process for your workload and will add a next one on spawn call in it unless poos_size is not exceeded.

=head1 VERSION

Version 0.01

=cut

$Poe::Wheel::Spawner::VERSION = '0.01';

=head1 SYNOPSIS

    use M43::POE::Wheel::Spawner;

    my $foo = M43::POE::Wheel::Spawner->new(
                pool_size => 2,
                stop_if_done => 1,
                workload => sub { _workload() }
        );

    $foo->run();

    sub _workload {
        
        # request for a a new sibling
        $foo->spawn($$);

        # ...
    }

=head1 SUBROUTINES/METHODS

=cut

=head2 new(%opts)

B<%opts> keys:

=over

=item pool_size

the number of maximal parallel executed B<workload>s

=item stop_if_done

stop after B<pool_size> pid's are exited.

run endless if !B<stop_if_done>

=item workload

CODE reference to execute

=back

=cut

sub new {
    my Poe::Wheel::Spawner $self = shift;
    my (%opts) = @_;
    unless (ref($self)) {
        $self = fields::new($self);
    }

    if (defined($opts{pool_size})) {
        $opts{pool_size} =~ /^\d+$/
            || die "'pool_size' property expects a positive integer value";
    }

    $self->{pool_size} = int(delete($opts{pool_size}) || 0);

    $self->{stop_if_done}       = delete($opts{stop_if_done});
    $self->{workload}           = delete($opts{workload});
    $self->{_workers_sig_count} = 0;

    %opts && warn sprintf("ignore unsupported properties '%s'", keys(%opts));

    return $self;
} ## end sub new

=head2 run(%opts)

%opts provide to POE::Session

=over

=item debug

default 0

=item trace

default 0

=back

create a POE::Session

run POE::Kernel

=cut

sub run {
    my ($self, %opts) = @_;

    ref($self->{workload}) eq 'CODE'
        || die "work_method is not a code reference";

    POE::Session->create(
        options => { debug => $opts{debug} || 0, trace => $opts{trace} || 0 },
        object_states => [
            $self => {
                _start     => '_handle_start',
                _next      => '_handle_start',
                _sig_child => '_handle_sig_child',
                _done      => '_handle_done',
                _stderr    => '_handle_stderr',
                _stdout    => '_handle_stdout',
            }
        ]
    );

    POE::Kernel->run();
} ## end sub run

=head2 spawn($pid)

print { busy_worker_pid => $pid } to stdout

=cut

sub spawn {
    my ($self, $pid) = @_;
    my $filter = POE::Filter::Reference->new();
    my $output = $filter->put([{ busy_worker_pid => $pid }]);

    print @$output;
} ## end sub spawn

=head2 _handle_start

handle B<_start> and B<_next> events defined in POE::Session, which is initialized in B<run>.

start execution of B<workload> by B<pool_size> parallel running pids

=cut

sub _handle_start {
    my ($self, $kernel, $heap) = @_[OBJECT, KERNEL, HEAP];

    my $pids_count = scalar(keys(%{ $heap->{worker_by_pid} }));
    ($pids_count >= $self->{pool_size}) && return;

    my $w = POE::Wheel::Run->new(
        Program => sub { &{ $self->{workload} } },
        StdoutFilter => POE::Filter::Reference->new(),
        StdoutEvent  => "_stdout",
        StderrEvent  => "_stderr",
        CloseEvent   => "_done",
    );

    $heap->{worker_by_pid}->{ $w->PID } = $w;
    $kernel->sig_child($w->PID, "_sig_child");
} ## end sub _handle_start

=head2 _handle_sig_child

Clear heap. Trigger '_next' if !stop_if_done and currently no child is busy

=cut

sub _handle_sig_child {
    my ($self, $kernel, $heap, $pid, $exit_val)
        = @_[OBJECT, KERNEL, HEAP, ARG1, ARG2];

    ++$self->{_workers_sig_count};

    my $child = delete $heap->{worker_by_pid}{$pid};
    unless ($child) {
        POE::Kernel::_die("no child pid: $pid");
    }

    delete $heap->{busy_worker_pid}->{$pid};

    if ($self->{stop_if_done}) {
        ($self->{_workers_sig_count} >= $self->{pool_size}) && return;
    }
    else {
        (scalar(keys(%{ $heap->{busy_worker_pid} })))
            || $kernel->yield("_next");
    }
} ## end sub _handle_sig_child

=head2 _handle_done

is not implemented yet

=cut

sub _handle_done { }

=head2 _handle_stderr

provide STDERR to POE::Kernel::_warn

=cut

sub _handle_stderr {
    my ($self, $input, $wheel_id) = @_[OBJECT, ARG0, ARG1];
    POE::Kernel::_warn("wheel $wheel_id STDERR: $input");
}

=head2 _handle_stdout

evaluate from child to stdout printed result.

trigger _next event if child asks - by using busy_worker_pid printed to stdout - for a sibling

=cut

sub _handle_stdout {
    my ($self, $kernel, $heap, $result) = @_[OBJECT, KERNEL, HEAP, ARG0];
    if (ref($result) eq 'HASH' && $result->{busy_worker_pid}) {
        $heap->{busy_worker_pid}->{ $result->{busy_worker_pid} } = 1;
        $kernel->yield("_next");
    }
} ## end sub _handle_stdout

1;    # End of Poe::Wheel::Spawner

=head1 AUTHOR

Alexei Pastuchov E<lt>palik at cpan.orgE<gt>.

=head1 BUGS

Please report any bugs or feature requests to C<bug-poe-wheel-spawner at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Poe-Wheel-Spawner>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Poe::Wheel::Spawner


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Poe-Wheel-Spawner>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Poe-Wheel-Spawner>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Poe-Wheel-Spawner>

=item * Search CPAN

L<http://search.cpan.org/dist/Poe-Wheel-Spawner/>

=back


=head1 REPOSITORY

L<https://github.com/p-alik/Poe-Wheel-Spawner.git>

=head1 LICENSE AND COPYRIGHT


Copyright 2014 by Alexei Pastuchov E<lt>palik at cpan.orgE<gt>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
