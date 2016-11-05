#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'API::X';

subtest 'Checking methods' => sub {
    my @methods = qw(throw);

    can_ok('API::X', @methods);
};

done_testing();
