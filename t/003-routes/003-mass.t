#!/usr/bin/env perl
use strict;
use warnings;

use JSON::XS qw(decode_json);
use Test::Most;
use Dancer::Test;
use Dancer ':syntax';

use_ok 'API::Routes::Mass';

subtest 'Retention routes' => sub {
    route_exists [GET => '/api/v1/mass/3588.26127'], "Mass route exists";
    response_status_is [GET => '/api/v1/mass/3588.26127'], 200, "response for GET /api/v1/mass/:mass is 200";


    route_exists [GET => '/api/v1/mass/average/3588.26127'], "Mass route exists";
    response_status_is [GET => '/api/v1/mass/average/3588.26127'], 200, "response for GET /api/v1/mass/:mass is 200";


    route_exists [GET => '/api/v1/mass/monoisotopic/3588.26127'], "Mass route exists";
    response_status_is [GET => '/api/v1/mass/monoisotopic/3588.26127'], 200, "response for GET /api/v1/mass/:mass is 200";
};

done_testing();
