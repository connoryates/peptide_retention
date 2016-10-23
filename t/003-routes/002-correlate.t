#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Dancer ':syntax';
use Dancer::Test;

use_ok 'API::Routes::Correlate';

subtest 'Retention routes' => sub {
    route_exists [POST => '/api/v1/correlate/bull_breese/peptide_length'], "Retention correlate";
    response_status_is [
            POST => '/api/v1/correlate/bull_breese/peptide_length?peptide_length=17'
        ],
        200,
        "response for POST /api/v1/correlate/bull_breese/peptide_length is 200";
};

done_testing();
