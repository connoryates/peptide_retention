#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'API::Cache::Peptide';

my $cache = API::Cache::Peptide->new;

isa_ok($cache, 'API::Cache::Peptide');
isa_ok($cache, 'API::Cache');

my $peptide = 'K';

# The peptide key is deleted in set_peptide_cache, so use a variable for it
my $payload = {
    method         => 'test',
    peptide        => $peptide,
    retention_info => '-1.4',
};

subtest 'Checking methods' => sub {
    my @methods = qw(get_peptide_cache set_peptide_cache);

    can_ok($cache, @methods);
};

subtest 'Testing set_peptide_cache' => sub {
    my $status = $cache->set_peptide_cache($payload);

    is(defined($status), 1, "set_peptide_cache is successful");
};

subtest 'Testing set_peptide_cache' => sub {
    my $cached = $cache->get_peptide_cache($peptide);

    delete $payload->{peptide};

    is_deeply($cached, $payload, "get_peptide_cache is successful");
};

done_testing();
