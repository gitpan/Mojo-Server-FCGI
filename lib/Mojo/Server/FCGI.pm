# Copyright (C) 2008-2009, Sebastian Riedel.

package Mojo::Server::FCGI;

use strict;
use warnings;

use base 'Mojo::Server';
use bytes;

use FCGI;

use constant CHUNK_SIZE => $ENV{MOJO_CHUNK_SIZE} || 4096;

our $VERSION = '0.16';

# Wow! Homer must have got one of those robot cars!
# *Car crashes in background*
# Yeah, one of those AMERICAN robot cars.
sub process {
    my $self = shift;

    my $tx  = $self->build_tx_cb->($self);
    my $req = $tx->req;

    # Environment
    $req->parse(\%ENV);

    # Request body
    while (!$req->is_state(qw/done error/)) {
        my $read = STDIN->sysread(my $buffer, CHUNK_SIZE, 0);
        $req->parse($buffer);
        last if $read <= 0;
    }

    # Handle
    $self->handler_cb->($self, $tx);

    my $res = $tx->res;

    # Status
    my $code = $res->code;
    my $message = $res->message || $res->default_message;
    $res->headers->status("$code $message") unless $res->headers->status;

    # Response headers
    my $offset = 0;
    while (1) {
        my $chunk = $res->get_header_chunk($offset);

        # No headers yet, try again
        unless (defined $chunk) {
            sleep 1;
            next;
        }

        # End of headers
        last unless length $chunk;

        # Headers
        return unless defined STDOUT->syswrite($chunk);
        $offset += length $chunk;
    }

    # Response body
    $offset = 0;
    while (1) {
        my $chunk = $res->get_body_chunk($offset);

        # No content yet, try again
        unless (defined $chunk) {
            sleep 1;
            next;
        }

        # End of content
        last unless length $chunk;

        # Content
        return unless defined STDOUT->syswrite($chunk);
        $offset += length $chunk;
    }

    return 1;
}

sub run {
    my $self = shift;

    # Preload
    $self->app;

    # Loop
    my $request = FCGI::Request();
    while ($request->Accept() >= 0) {
        $self->process;
    }
}

1;
__END__

=head1 NAME

Mojo::Server::FCGI - Speedy FastCGI Server

=head1 SYNOPSIS

    use Mojo::Server::FCGI;
    my $fcgi = Mojo::Server::FCGI->new;
    $fcgi->run;

=head1 DESCRIPTION

L<Mojo::Server::FCGI> is a very speedy FastCGI implementation using L<FCGI>
and the preferred deployment option for production servers under heavy load.

=head1 ATTRIBUTES

L<Mojo::Server::FCGI> inherits all attributes from L<Mojo::Server>.

=head1 METHODS

L<Mojo::Server::FCGI> inherits all methods from L<Mojo::Server> and
implements the following new ones.

=head2 C<process>

    $fcgi->process;

=head2 C<run>

    $fcgi->run;

=head1 SEE ALSO

L<Mojo>

=head1 AUTHOR

Sebastian Riedel, C<sri@cpan.org>.

=head1 CREDITS

In alphabetical order:

Kevin Old

Viacheslav Tikhanovskii

=head1 COPYRIGHT

Copyright (C) 2008-2009, Sebastian Riedel.

=head1 LICENSE

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
