#!/usr/bin/env perl -w

# Copyright (C) 2008, Sebastian Riedel.

use 5.008001;

use strict;
use warnings;

# Son, when you participate in sporting events,
# it's not whether you win or lose, it's how drunk you get.
use ExtUtils::MakeMaker;

my $mm = $ExtUtils::MakeMaker::VERSION;

WriteMakefile(
    NAME         => 'Mojo::Server::FCGI',
    VERSION_FROM => 'lib/Mojo/Server/FCGI.pm',
    AUTHOR       => 'Sebastian Riedel <sri@cpan.org>',

    ($mm < 6.3002 ? () : ('LICENSE' => 'perl',)),

    (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                resources => {
                    license    => 'http://dev.perl.org/licenses/',
                    homepage   => 'http://mojolicious.org',
                    repository => 'http://github.com/kraih/mojo/tree/master',
                    MailingList =>
                      'http://lists.kraih.com/cgi-bin/mailman/listinfo',
                },
                no_index => {directory => [qw/t/],},
            },
            META_ADD => {
                configure_requires => {},
                build_requires     => {},
            },
        )
    ),

    PREREQ_PM => {'FCGI' => '0.67', 'Mojo' => '0.991236'},
    test      => {TESTS  => 't/*.t t/*/*.t t/*/*/*.t'}
);
