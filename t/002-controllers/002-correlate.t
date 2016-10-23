#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'API::Controllers::Correlate';

my $controller = API::Controllers::Correlate->new;

isa_ok ($controller, 'API::Controllers::Correlate');

subtest 'Checking methods' => sub {
    my @methods = qw(correlate_peptides);

    can_ok($controller, @methods);
};

done_testing();
