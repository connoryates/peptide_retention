#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'API::Cache::Peptide';

my $cache = API::Cache::Peptide->new;

isa_ok($cache, 'API::Cache::Peptide');
isa_ok($cache, 'API::Cache');

my $peptide = 'K';

my $payload = {
    peptide        => $peptide,
    retention_info => {
        hodges_prediction => '-1.4',
        bullbreese        => '0.460',
        length            => 1,
    },
};

subtest 'Checking methods' => sub {
    my @methods = qw(get_peptide_cache set_peptide_cache is_cached remove_key);

    can_ok($cache, @methods);
};

subtest 'Testing set_peptide_cache' => sub {
    my $status = $cache->set_peptide_cache($payload);

    is(defined($status), 1, "set_peptide_cache is successful");
};

subtest 'Testing get_peptide_cache' => sub {
    my $cached = $cache->get_peptide_cache($peptide);

    is_deeply($cached, $payload->{retention_info}, "get_peptide_cache is successful");
};

subtest 'Testing next search results' => sub {
    my $query = {
        keywords => 'mannosyltransferase',
        length   => 17,
        limit    => 100,
        offset   => 100,
    };

    my $id = $cache->set_next_search($query);

    my $cached = $cache->get_next_search($id);

    is_deeply($query, $cached, 'Got cached data structure');
};

done_testing();
