#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'API::Controllers::Peptides';

my $controller = API::Controllers::Peptides->new;

isa_ok($controller, 'API::Controllers::Peptides');

subtest 'Checking methods' => sub {
    my @methods = qw(retention_info add_retention_info);

    can_ok($controller, @methods);
};

done_testing();
