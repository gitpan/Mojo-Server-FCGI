# Copyright (C) 2008-2009, Sebastian Riedel.

package Mojo::Command::Fcgi;

use strict;
use warnings;

use base 'Mojo::Command';

use Mojo::Server::FCGI;

__PACKAGE__->attr(description => <<'EOF');
Start application with FCGI backend.
EOF
__PACKAGE__->attr(usage => <<"EOF");
usage: $0 fcgi
EOF

# Oh boy! Sleep! That's when I'm a Viking!
sub run {
    Mojo::Server::FCGI->new->run;
    return shift;
}

1;
__END__

=head1 NAME

Mojo::Command::Fcgi - FCGI Command

=head1 SYNOPSIS

    use Mojo::Command::Fcgi;

    my $fcgi = Mojo::Command::Fcgi->new;
    $fcgi->run(@ARGV);

=head1 DESCRIPTION

L<Mojo::Command::Fcgi> is a command interface to L<Mojo::Server::FCGI>.

=head1 ATTRIBUTES

L<Mojo::Command::Fcgi> inherits all attributes from L<Mojo::Command> and
implements the following new ones.

=head2 C<description>

    my $description = $fcgi->description;
    $fcgi           = $fcgi->description('Foo!');

=head2 C<usage>

    my $usage = $fcgi->usage;
    $fcgi     = $fcgi->usage('Foo!');

=head1 METHODS

L<Mojo::Command::Fcgi> inherits all methods from L<Mojo::Command> and
implements the following new ones.

=head2 C<run>

    $fcgi = $fcgi->run(@ARGV);

=cut
