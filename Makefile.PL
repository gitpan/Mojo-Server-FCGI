#!/usr/bin/env perl

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
    ABSTRACT     => 'Speedy FastCGI implementation',
    AUTHOR       => 'Sebastian Riedel <sri@cpan.org>',

    ($mm < 6.3002 ? () : ('LICENSE' => 'artistic_2',)),

    (   $mm < 6.46
        ? ()
        : ( META_MERGE => {
                requires  => {perl => '5.008001'},
                resources => {
                    license    => 'http://dev.perl.org/licenses/',
                    homepage   => 'http://mojolicious.org',
                    repository => 'http://github.com/kraih/mojo',
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

    PREREQ_PM => {
        'Carp'                => 0,
        'ExtUtils::MakeMaker' => 0,
        'FCGI'                => '0.67',
        'File::Spec'          => 0,
        'File::Temp'          => 0,
        'FindBin'             => 0,
        'Getopt::Long'        => 0,
        'Mojo'                => '0.999920',
        'Test::More'          => 0,
    },
    test => {TESTS => 't/*.t t/*/*.t t/*/*/*.t'}
);
