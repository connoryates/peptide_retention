#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Test::Exception;

use_ok 'Peptide::Model';

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

my $peptide = 'KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK';

subtest 'Testing add_retention_info' => sub {
    plan skip_all => 'Skipping - comment this out and add a new peptide to test';

    my $payload = {
        retention_info  => {
            sequence            => $peptide,
            cleavage            => 'tryptic',
            real_retention_time => 2,
        },
        prediction_info => {
            algorithm   => 'test_2',
            prediction  => 2,
        }, 
        protein_info => {
            name        => 'test_2',
            description => 'test_2',
        },
    };

    $model->add_retention_info($payload);

    my $result = $model->schema->peptide->find({ sequence => $payload->{retention_info}->{sequence} });

    my $expect  = {
       id                  => 21,
       length              => undef,
       real_retention_time => 2,
       bullbreese          => 23.92,
       sequence            => 'KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK',
       molecular_weight    => 6664.84,
       cleavage            => 'tryptic'
    };

    is_deeply($result->{_column_data}, $expect, "Got expected retention_info");
};

done_testing();
