#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'Peptide::Retention';

my $ret = Peptide::Retention->new;

isa_ok($ret, 'Peptide::Retention');

subtest 'Checking methods' => sub {
    my @methods = qw(tryptic_vals );

    can_ok($ret, @methods);
};

subtest 'Testing tryptic_vals' => sub {
    my $vals = $ret->tryptic_vals('R');

    my $expect = {
        predicition_info => [
            {
                predicted_time => -0.6,
                algorithm      => 'hodges'
            }
        ],
        retention_info => {
            length     => 1,
            sequence   => 'R',
            bullbreese => 0.69,
            cleavage   => 'tryptic'
        }
    };

    is_deeply($vals, $expect, "tryptic_vals successful");
};

done_testing();
