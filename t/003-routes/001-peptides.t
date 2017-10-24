#!/usr/bin/env perl
use strict;
use warnings;

use JSON::XS qw(decode_json);
use Test::Most;
use Dancer::Test;
use Dancer ':syntax';

use_ok 'API::Routes::Peptides';

subtest 'Retention routes' => sub {
    route_exists [GET => '/api/v1/peptide/GIITSTVDWKPIK'], "Retention info exists";
    response_status_is [GET => '/api/v1/peptide/GIITSTVDWKPIK'], 200, "response for GET /api/v1/peptide/:peptide is 200";

    response_status_is [GET => '/api/v1/peptide'], 404, "response for POST /api/v1/peptide without peptide is 404";


    route_exists [POST => '/api/v1/peptide/add'], "Peptide add exists";


    route_exists [POST => '/api/v1/peptide/search'], "Peptide search exists";
    my $resp = dancer_response(
        POST => '/api/v1/peptide/search',
            {
                params => {
                    keywords => 'mannosyltransferase',
                    length   => 17,
                    limit    => 100,
                }
            }
    );

    my $content = decode_json($resp->content);

    my $uuid_regexp = qr/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/;

    is($resp->status, 200, "response for POST /api/v1/peptide/search is 200");
    like($content->{next}, $uuid_regexp, 'Got uuid back from request');

    my $next_resp = dancer_response(
        POST => '/api/v1/peptide/search/next',
            {
                params => {
                    next => $content->{next},
                },
            }
    );

    my $next_content = decode_json($next_resp->content);

    is($next_resp->status, 200, "response for POST /api/v1/peptide/search/next is 200");
    like($content->{next}, $uuid_regexp, "Got uuid back from request");


    diag 'Testing get peptides by length';
    
    route_exists [GET => '/api/v1/peptide/length/17'], "Peptide length exists";
    response_status_is [GET => '/api/v1/peptide/length/17'], 200, "response for GET /api/v1/peptide/length/:length is 200";
};

done_testing();
