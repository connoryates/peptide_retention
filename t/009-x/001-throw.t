#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Test::Exception;

use_ok 'API::X';

subtest 'Checking methods' => sub {
    my @methods = qw(throw);

    can_ok('API::X', @methods);
};

subtest 'Testing throw' => sub {
    throws_ok(
        sub {
            API::X->throw({
                message => 'Test',
            });
        },
        qr/Test/,
        "Throw is ok",
    );

    dies_ok {
       API::X->throw({
           message => 'Test',
       });
    } "Throw dies ok";
};

done_testing();
