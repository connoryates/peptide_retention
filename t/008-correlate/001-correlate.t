#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'Peptide::Correlation';

my $corr = Peptide::Correlation->new;

isa_ok($corr, 'Peptide::Correlation');

subtest 'Checking methods' => sub {
    my @methods = qw(correlate_retention_datasets correlate);

    can_ok($corr, @methods);
};

done_testing();
