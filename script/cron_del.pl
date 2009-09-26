#!/usr/bin/perl

use strict;
use warnings;

my $status = `wget -q -O - http://mix3.moe.hm/pixiv_rss/cron/del`;
warn $status;
