#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Dancer::Test;
use Dancer ':syntax';

use_ok 'API::Routes::Peptides';

subtest 'Retention routes' => sub {
    route_exists [POST => '/api/v1/retention/peptide/info'], "Retention info";
    response_status_is [POST => '/api/v1/retention/peptide/info?peptide=R'], 200, "response for POST /api/v1/retention/peptide/info is 200";
};

done_testing();
