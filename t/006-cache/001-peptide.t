#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'API::Cache::Peptide';

my $cache = API::Cache::Peptide->new;

isa_ok($cache, 'API::Cache::Peptide');
isa_ok($cache, 'API::Cache');

subtest 'Checking methods' => sub {
    my @methods = qw(get_peptide_cache set_peptide_cache);

    can_ok($cache. @methods);
};

done_testing();
