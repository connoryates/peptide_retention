#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Test::Exception;

use_ok 'API::Elasticsearch';

my $elasticsearch = API::Elasticsearch->new();

isa_ok($elasticsearch, 'API::Elasticsearch');

subtest 'Testing search_peptide' => sub {
    my $result = $elasticsearch->search_peptide({
        keywords => 'mannosyltransferase',
    });

    use Data::Dumper;
    print Dumper $result;
};

done_testing();
