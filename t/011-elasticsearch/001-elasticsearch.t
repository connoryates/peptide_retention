#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Test::Exception;

use_ok 'API::Elasticsearch';

my $elasticsearch = API::Elasticsearch->new;

isa_ok($elasticsearch, 'API::Elasticsearch');

subtest 'Checking methods' => sub {
    my @methods = qw(peptide_index peptide_search _current_date);

    can_ok($elasticsearch, @methods);
};

subtest 'Testing _current_date' => sub {
    my $date = $elasticsearch->_current_date;

    like($date, qr/^\d{4}-\d{2}-\d{2}$/, "Got date only");
};

done_testing();
