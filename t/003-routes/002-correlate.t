#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Dancer ':syntax';
use Dancer::Test;

use_ok 'API::Routes::Correlate';

subtest 'Retention routes' => sub {
    plan skip_all => "ENV{CORRELATION_TESTS} not set" unless defined $ENV{CORRELATION_TESTS};

    route_exists [GET => '/api/v1/correlate/bullbreese'], "Retention correlate";
    response_status_is [
            GET => '/api/v1/correlate/bullbreese'
        ],
        200,
        "response for GET /api/v1/correlate/bullbreese is 200";


    route_exists [GET => '/api/v1/correlate/bullbreese/length/3'], "Retention correlate";
    response_status_is [
            GET => '/api/v1/correlate/bullbreese/length/3'
        ],
        200,
        "response for GET /api/v1/correlate/bullbreese is 200";
};

done_testing();
