#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Dancer::Test;
use Dancer ':syntax';

use_ok 'API::Routes::Correlate';

subtest 'Retention routes' => sub {
    route_exists [POST => '/api/v1/retention/correlate'], "Retention correlate";
    response_status_is [POST => '/api/v1/retention/correlate?peptide_length=17'], 200, "response for POST /api/v1/retention/correlate is 200";
};

done_testing();
