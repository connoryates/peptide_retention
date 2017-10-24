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
        keywords => 'Chromosome IX cosmid 9168 OS=Saccharomyces cerevisiae (strain ATCC 204508 / S288c) PE=4 SV=1',
    });

    use Data::Dumper;
    print Dumper $result;
};

done_testing();
