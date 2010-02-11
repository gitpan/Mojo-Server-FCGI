# Copyright (C) 2008-2010, Sebastian Riedel.

package Mojo::Server::FCGI::Prefork;

use strict;
use warnings;

use base 'Mojo::Server::Daemon::Prefork';

use Carp 'croak';
use Mojo::Server::FCGI;
use Socket;

__PACKAGE__->attr(fcgi   => sub { Mojo::Server::FCGI->new });
__PACKAGE__->attr(listen => sub {':3000'});

__PACKAGE__->attr(_env => sub { {} });
__PACKAGE__->attr('_req');

# Yeah, Moe, that team sure did suck last night. They just plain sucked!
# I've seen teams suck before,
# but they were the suckiest bunch of sucks that ever sucked!
# HOMER!
# I gotta go Moe my damn weiner kids are listening.
sub child {
    my $self = shift;

    # Lock
    $self->accept_lock;

    # Idle
    $self->child_status('idle');

    # Accept
    $self->_req->Accept();

    # Busy
    $self->child_status('busy');

    # Unlock
    $self->accept_unlock;

    # Process
    $self->fcgi->process($self->_env);
}

sub parent {
    my $self = shift;

    my $listen = $self->listen;
    my $l = FCGI::OpenSocket($listen, $self->listen_queue_size || SOMAXCONN);
    croak "Can't create listen socket: $!" unless $l;
    print "Server available at $listen.\n";

    $self->_req(
        FCGI::Request(
            \*STDIN,     \*STDOUT, \*STDERR,
            $self->_env, $l,       FCGI::FAIL_ACCEPT_ON_INTR
        )
    );
}

1;
__END__

=head1 NAME

Mojo::Server::FCGI::Prefork - Prefork FastCGI Server

=head1 SYNOPSIS

    use Mojo::Server::FCGI::Prefork;
    my $prefork = Mojo::Server::FCGI::Prefork->new;
    $prefork->run;

=head1 DESCRIPTION

L<Mojo::Server::FCGI::Prefork> is a preforking FastCGI implementation using
L<FCGI>.

=head1 ATTRIBUTES

L<Mojo::Server::FCGI::Prefork> inherits all attributes from L<Mojo::Server>
and implements the following new ones.

=head2 C<fcgi>

    my $fcgi = $prefork->fcgi;
    $prefork = $prefork->fcgi(Mojo::Server::FCGI->new);

    $prefork->fcgi->app_class('Mojo::HelloWorld');

=head2 C<listen>

    my $listen = $prefork->listen
    $prefork   = $prefork->listen(':3000');
    $prefork   = $prefork->listen('/some/unix.socket');

=head1 METHODS

L<Mojo::Server::FCGI> inherits all methods from L<Mojo::Server> and
implements the following new ones.

=head2 C<child>

    $prefork->child;

=head2 C<parent>

    $prefork->parent;

=cut
