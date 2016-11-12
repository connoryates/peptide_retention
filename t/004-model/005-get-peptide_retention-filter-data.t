#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Test::Exception;
use Data::Dumper;

use_ok 'Peptide::Model';

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

subtest 'Checking methods' => sub {
    my @methods = qw(get_peptide_retention_filtered_data);

    can_ok($model, @methods);
};

subtest 'Testing get_peptide_retention_filtered_data' => sub {
    my $filter = 'peptide_length';
    my $data   = 12;

    my $correlation = $model->get_peptide_retention_filtered_data({
        filter => $filter,
        data   => $data,
    });

    isa_ok($correlation, 'ARRAY', "At least we got data");
};

done_testing();
