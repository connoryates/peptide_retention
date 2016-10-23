#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'Peptide::Model';

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

subtest 'Checking methods' => sub {
    my @methods = qw(
        add_retention_info _get_retention_info
        add_retention_info get_bb_retention_correlation_data
        get_peptide_retention_correlation_data
        get_peptide_retention_filtered_data
        _peptide_length_filter get_bar_chart_peptide_data
        validate_api_key
    );

    can_ok($model, @methods);
};

subtest 'Testing get_retention_info' => sub {
    my $expect = {
        retention_info => {
            prediction_algorithm => 'hodges',
            length               => 1,
            predicted_retention  => '-2.1',
            bullbreese           => '0.46',
            peptide              => 'K'
        }
    };

    my $ret_info = $model->get_retention_info('K');

    is_deeply($ret_info, $expect, "get_retention_info successful");
};

subtest 'Testing _get_retention_info' => sub {
    my $expect = {
        retention_info => {
            prediction_algorithm => 'hodges',
            length               => 1,
            predicted_retention  => '-2.1',
            bullbreese           => '0.46',
            peptide              => 'K'
        }
    };

    my $ret_info = $model->_get_retention_info('K');

    is_deeply($ret_info, $expect, "_get_retention_info successful");
};

done_testing();
