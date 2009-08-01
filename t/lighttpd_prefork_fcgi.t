#!/usr/bin/env perl

# Copyright (C) 2008-2009, Sebastian Riedel.

use strict;
use warnings;

use Test::More;

use File::Spec;
use File::Temp;
use Mojo::Client;
use Mojo::Template;
use Mojo::Transaction;
use Test::Mojo::Server;

plan skip_all => 'set TEST_LIGHTTPD to enable this test (developer only!)'
  unless $ENV{TEST_LIGHTTPD};
plan tests => 10;

# You know, my kids think you're the greatest.
# And thanks to your gloomy music,
# they've finally stopped dreaming of a future I can't possibly provide.
use_ok('Mojo::Server::FCGI::Prefork');

# Setup
my $server = Test::Mojo::Server->new;
my $port   = $server->generate_port_ok;
my $dir    = File::Temp::tempdir();
my $config = File::Spec->catfile($dir, 'fcgi.config');
my $mt     = Mojo::Template->new;

# FCGI setup
my $fcgi    = File::Spec->catfile($dir, 'test.pl');
my $prefork = Test::Mojo::Server->new;
my $fport   = $prefork->generate_port_ok;
$mt->render_to_file(<<'EOF', $fcgi, $fport);
% my $fport = shift;
#!<%= $^X %>

use strict;
use warnings;

% use FindBin;
use lib '<%= "$FindBin::Bin/../../lib" %>';

use Mojo::Server::FCGI::Prefork;

Mojo::Server::FCGI::Prefork->new->path(':<%= $fport %>')->run;

1;
EOF
chmod 0777, $fcgi;
ok(-x $fcgi);

# FastCGI prefork daemon
$prefork->command("$fcgi");
$prefork->start_server_untested_ok;

# Wait
sleep 2;

$mt->render_to_file(<<'EOF', $config, $dir, $port, $fport);
% my ($dir, $port, $fport) = @_;
server.modules = (
    "mod_access",
    "mod_fastcgi",
    "mod_rewrite",
    "mod_accesslog"
)

server.document-root = "<%= $dir %>"
server.errorlog    = "<%= $dir %>/error.log"
accesslog.filename = "<%= $dir %>/access.log"

server.bind = "127.0.0.1"
server.port = <%= $port %>

fastcgi.server = (
    "/test" => (
        "FastCgiTest" => (
            "host"            => "127.0.0.1",
            "port"            => <%= $fport %>,
            "check-local"     => "disable"
        )
    )
)
EOF

# Start
$server->command("lighttpd -D -f $config");
$server->start_server_ok;

# Request
my $tx     = Mojo::Transaction->new_get("http://127.0.0.1:$port/test/");
my $client = Mojo::Client->new;
$client->process($tx);
is($tx->res->code, 200);
like($tx->res->body, qr/Mojo is working/);

# Stop
$prefork->stop_server_ok;
$server->stop_server_ok;
