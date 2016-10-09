#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Dancer::Test;
use Dancer ':syntax';
use Furl;

use_ok 'API::Routes::Peptides';

subtest 'Retention routes' => sub {
    route_exists [POST => '/api/v1/retention/peptide/info'], "Retention info";
    response_status_is [POST => '/api/v1/retention/peptide/info?peptide=R'], 200, "response for POST /api/v1/retention/peptide/info is 200";
    my $resp = Furl->new->post('http://0.0.0.0:5000/api/v1/retention/peptide/info', [], {peptide => 'R'});
    use Data::Dumper;
    print Dumper $resp;
};

done_testing();
