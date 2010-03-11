# Copyright (C) 2008-2010, Sebastian Riedel.

package Mojo::Command::FcgiPrefork;

use strict;
use warnings;

use base 'Mojo::Command';

use Mojo::Server::FCGI::Prefork;

use Getopt::Long 'GetOptions';

__PACKAGE__->attr(description => <<'EOF');
Start application with preforking FCGI backend.
EOF
__PACKAGE__->attr(usage => <<"EOF");
usage: $0 fcgi_prefork [OPTIONS]

These options are available:
  --daemonize             Daemonize parent.
  --group <name>          Set group name for children.
  --idle <seconds>        Set time children can be idle without getting
                          killed, defaults to 30.
  --interval <seconds>    Set interval for process maintainance, defaults to
                          15.
  --listen <path>         Set listen socket path, defaults to :3000.
  --lock <path>           Set path to lock file, defaults to a random
                          temporary file.
  --maxspare <number>     Set maximum amount of idle children, defaults to 10.
  --minspare <number>     Set minimum amount of idle children, defaults to 5.
  --pid <path>            Set path to pid file, defaults to a random
                          temporary file.
  --reload                Automatically reload application when the source
                          code changes.
  --servers <number>      Set maximum number of children, defaults to 100.
  --start <number>        Set number of children to spawn at startup,
                          defaults to 5.
  --user <name>           Set user name for children.
EOF

# Oh boy! Sleep! That's when I'm a Viking!
sub run {
    my $self = shift;
    my $fcgi = Mojo::Server::FCGI::Prefork->new;

    # Options
    my $daemonize;
    @ARGV = @_ if @_;
    GetOptions(
        daemonize    => \$daemonize,
        'group=s'    => sub { $fcgi->group($_[1]) },
        'idle=i'     => sub { $fcgi->idle_timeout($_[1]) },
        'interval=i' => sub { $fcgi->cleanup_interval($_[1]) },
        'listen=s'   => sub { $fcgi->listen($_[1]) },
        'lock=s'     => sub { $fcgi->lock_file($_[1]) },
        'maxspare=i' => sub { $fcgi->max_spare_servers($_[1]) },
        'minspare=i' => sub { $fcgi->min_spare_servers($_[1]) },
        'pid=s'      => sub { $fcgi->pid_file($_[1]) },
        reload       => sub { $fcgi->reload(1) },
        'servers=i'  => sub { $fcgi->max_servers($_[1]) },
        'start=i'    => sub { $fcgi->start_servers($_[1]) },
        'user=s'     => sub { $fcgi->user($_[1]) }
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

Mojo::Command::FcgiPrefork - FCGI Prefork Command

=head1 SYNOPSIS

    use Mojo::Command::FcgiPrefork;

    my $fcgi = Mojo::Command::FcgiPrefork->new;
    $fcgi->run(@ARGV);

=head1 DESCRIPTION

L<Mojo::Command::FcgiPrefork> is a command interface to
L<Mojo::Server::FCGI::Prefork>.

=head1 ATTRIBUTES

L<Mojo::Command::FcgiPrefork> inherits all attributes from L<Mojo::Command>
and implements the following new ones.

=head2 C<description>

    my $description = $fcgi->description;
    $fcgi           = $fcgi->description('Foo!');

Short description of this command, used for the command list.

=head2 C<usage>

    my $usage = $fcgi->usage;
    $fcgi     = $fcgi->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Mojo::Command::FcgiPrefork> inherits all methods from L<Mojo::Command> and
implements the following new ones.

=head2 C<run>

    $fcgi = $fcgi->run(@ARGV);

Run this command.

=cut
