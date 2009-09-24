#!/usr/bin/perl

use strict;
use warnings;
use FindBin::libs;
use Cwd 'realpath';

use Getopt::Long;

GetOptions(
   \my %options,
   qw/nproc=i listen=s keep_stderr/,
);

use NewPixivRSS;
use HTTP::Engine::Middleware;
use HTTP::Engine;

my $app = NewPixivRSS->new;
$app->setup;

#my $mw = HTTP::Engine::Middleware->new;
#$mw->install('HTTP::Engine::Middleware::Static' => {
#   docroot => $app->path_to('root'),
#   regexp => '/(?:(?:css|js|img|images?|swf|static|tmp|)/.*|[^/]+\.[^/]+)',
#});

HTTP::Engine->new(
   interface => {
      module => 'FCGI',
      request_handler => $app->handler,
   },
)->run;
