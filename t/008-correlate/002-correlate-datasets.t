#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Test::Exception;

use_ok 'Peptide::Correlation';

my $correlation = Peptide::Correlation->new(
    type => 'bullbreese_retention',
);

isa_ok($correlation, 'Peptide::Correlation');

subtest 'Checking methods' => sub {
    my @methods = qw(correlate_retention_datasets);

    can_ok($correlation, @methods);
};

subtest 'Testing correlate_retention_datasets with bullbreese values' => sub {
    plan skip_all => 'ENV{CORRELATION_TESTS} not set' unless defined $ENV{CORRELATION_TESTS};

    my $filter = {
        filter => 'peptide_length',
        data   => 4,
    };

    my $corr   = $correlation->correlate_retention_datasets($filter);

    isnt('n/a', $corr, "Got a number at least");
};

subtest 'Testing correlate_retention_datasets with lengths' => sub {
    plan skip_all => 'ENV{CORRELATION_TESTS} not set' unless defined $ENV{CORRELATION_TESTS};

    my $corr = $correlation->correlate_retention_datasets();

    print "corr => $corr\n";

    isnt('n/a', $corr, "Got a number at least");
};

done_testing();
