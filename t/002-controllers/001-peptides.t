#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'API::Controllers::Peptides';

my $controller = API::Controllers::Peptides->new;

can_ok($controller, qw(retention_info add_retention_info));

done_testing();
