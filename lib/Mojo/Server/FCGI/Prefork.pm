# Copyright (C) 2008-2009, Sebastian Riedel.

package Mojo::Server::FCGI::Prefork;

use strict;
use warnings;

use base 'Mojo::Server::Daemon::Prefork';

use Mojo::Server::FCGI;

__PACKAGE__->attr('fcgi', default => sub { Mojo::Server::FCGI->new });
__PACKAGE__->attr('path', default => sub {':3000'});

# Yeah, Moe, that team sure did suck last night. They just plain sucked!
# I've seen teams suck before,
# but they were the suckiest bunch of sucks that ever sucked!
# HOMER!
# I gotta go Moe my damn weiner kids are listening.
sub child {
    my $self = shift;

    # Lock
    $self->accept_lock;

    # Accept
    $self->{req}->Accept();

    # Unlock
    $self->accept_unlock;

    # Process
    $self->fcgi->process;
}

sub parent {
    my $self = shift;

    my $path = $self->path;
    my $l = FCGI::OpenSocket($path, $self->listen_queue_size);
    die "Can't create listen socket: $!" unless $l;
    print "Server available at $path.\n";

    $self->{req} = FCGI::Request(\*STDIN, \*STDOUT, \*STDERR, \%ENV, $l,
        FCGI::FAIL_ACCEPT_ON_INTR);
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

=head2 C<path>

    my $path = $prefork->path
    $prefork = $prefork->path(':3000');
    $prefork = $prefork->path('/some/unix.socket');

=head1 METHODS

L<Mojo::Server::FCGI> inherits all methods from L<Mojo::Server> and
implements the following new ones.

=head2 C<child>

    $prefork->child;

=head2 C<parent>

    $prefork->parent;

=cut
