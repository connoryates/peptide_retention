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
        retention_info => {
           bullbreese        => '0.69',
           peptide           => 'R',
           hodges_prediction => '-0.6',
           length            => 1,
        }
    };

    is_deeply($vals, $expect, "tryptic_vals successful");
};

done_testing();
