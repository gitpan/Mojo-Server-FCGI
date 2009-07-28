# Copyright (C) 2008-2009, Sebastian Riedel.

package Mojo::Script::FcgiPrefork;

use strict;
use warnings;

use base 'Mojo::Script';

use Mojo::Server::FCGI::Prefork;

use Getopt::Long 'GetOptionsFromArray';

__PACKAGE__->attr('description', default => <<'EOF');
Start application with preforking FCGI backend.
EOF
__PACKAGE__->attr('usage', default => <<"EOF");
usage: $0 fcgi_prefork [OPTIONS]

These options are available:
  --clients <limit>       Set maximum number of concurrent clients per child,
                          defaults to 1.
  --daemonize             Daemonize process.
  --group <name>          Set group name for child processes.
  --idle <seconds>        Set time processes can be idle without getting
                          killed, defaults to 30.
  --interval <seconds>    Set interval for process maintainance, defaults to
                          15.
  --keepalive <seconds>   Set keep-alive timeout, defaults to 15.
  --listen <path>         Set listen socket path, defaults to :3000.
  --maxspare <number>     Set maximum amount of idle children, defaults to 10.
  --minspare <number>     Set minimum amount of idle children, defaults to 5.
  --pid <path>            Set path to pid file, defaults to a random
                          temporary file.
  --requests <number>     Set maximum number of requests per keep-alive
                          connection, defaults to 100.
  --servers <number>      Set maximum number of child processes, defaults to
                          100.
  --start <number>        Set number of children to spawn at startup,
                          defaults to 5.
  --user <name>           Set user name for child processes.
EOF

# Oh boy! Sleep! That's when I'm a Viking!
sub run {
    my $self = shift;
    my $fcgi = Mojo::Server::FCGI::Prefork->new;

    # Options
    my $daemonize;
    my @options = @_ ? @_ : @ARGV;
    GetOptionsFromArray(
        \@options,
        'clients=i'   => sub { $fcgi->max_clients($_[1]) },
        'daemonize'   => \$daemonize,
        'group=s'     => sub { $fcgi->group($_[1]) },
        'idle=i'      => sub { $fcgi->idle_timeout($_[1]) },
        'interval=i'  => sub { $fcgi->cleanup_interval($_[1]) },
        'keepalive=i' => sub { $fcgi->keep_alive_timeout($_[1]) },
        'listen=s'    => sub { $fcgi->path($_[1]) },
        'maxspare=i'  => sub { $fcgi->max_spare_servers($_[1]) },
        'minspare=i'  => sub { $fcgi->min_spare_servers($_[1]) },
        'pid=s'       => sub { $fcgi->pid_file($_[1]) },
        'requests=i'  => sub { $fcgi->max_keep_alive_requests($_[1]) },
        'servers=i'   => sub { $fcgi->max_servers($_[1]) },
        'user=s'      => sub { $fcgi->user($_[1]) }
    );

    # Daemonize
    $fcgi->daemonize if $daemonize;

    # Run
    $fcgi->run;

    return $self;
}

1;
__END__

=head1 NAME

Mojo::Script::FcgiPrefork - FCGI Prefork Script

=head1 SYNOPSIS

    use Mojo::Script::FcgiPrefork;

    my $fcgi = Mojo::Script::FcgiPrefork->new;
    $fcgi->run(@ARGV);

=head1 DESCRIPTION

L<Mojo::Script::FcgiPrefork> is a script interface to
L<Mojo::Server::FCGI::Prefork>.

=head1 ATTRIBUTES

L<Mojo::Script::FcgiPrefork> inherits all attributes from L<Mojo::Script>
and implements the following new ones.

=head2 C<description>

    my $description = $fcgi->description;
    $fcgi           = $fcgi->description('Foo!');

=head2 C<usage>

    my $usage = $fcgi->usage;
    $fcgi     = $fcgi->usage('Foo!');

=head1 METHODS

L<Mojo::Script::FcgiPrefork> inherits all methods from L<Mojo::Script> and
implements the following new ones.

=head2 C<run>

    $fcgi = $fcgi->run(@ARGV);

=cut
