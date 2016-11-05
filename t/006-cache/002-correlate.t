#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'API::Cache::Correlate';

my $cache = API::Cache::Correlate->new;

isa_ok($cache, 'API::Cache::Correlate');
isa_ok($cache, 'API::Cache');

my $filter = 'test';

my $test_data = {
    key         => $filter,
    correlation => 1,
};

subtest 'Checking methods' => sub {
    my @methods = qw(get_correlate_cache set_correlate_cache);

    can_ok($cache, @methods);
};

subtest 'Testing set_correlate_cache' => sub {
    $cache->remove_key($filter) if $cache->is_cached($filter);

    my $status = $cache->set_correlate_cache($test_data);

    is(defined($status), 1, "set_correlate_cache succeeded");
};

subtest 'Testing get_correlate_cache' => sub {
    my $data = $cache->get_correlate_cache($filter);

    is_deeply($data, $test_data, "get_correlate_cache return correct data");

    $cache->remove_key($filter);
};

done_testing();
