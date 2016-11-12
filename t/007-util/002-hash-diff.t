#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Test::Exception;

use_ok 'Peptide::Util';

my $util = Peptide::Util->new;

isa_ok($util, 'Peptide::Util');

subtest 'Checking methods' => sub {
    my @methods = qw(merge_if_different);

    can_ok($util, @methods);
};

subtest 'Testing different hashes' => sub {
    my $new = {
        sequence            => 'KKKKKKKKKKKK',
        length              => 13,
        bullbreese          => -13.89,
        molecular_weight    => 5503.9,
        real_retention_time => 9.45,
        cleavage            => 'tryptic',
    };

    my $orig = {
        sequence            => 'KKKKKKKKKKKK',
        length              => 13,
        bullbreese          => -13.89,
        molecular_weight    => 5503.9,
        real_retention_time => 9.46,
        cleavage            => 'tryptic',
    };

    my $combined = $util->merge_if_different($new, $orig);

    my $expect = {
        sequence            => 'KKKKKKKKKKKK',
        length              => 13,
        bullbreese          => -13.89,
        molecular_weight    => 5503.9,
        real_retention_time => 9.45,
        cleavage            => 'tryptic',
    };

    is_deeply($combined, $expect, "Got correct combined hash");
};

subtest 'Testing same hashes' => sub {
    my $new = {
        sequence            => 'KKKKKKKKKKKK',
        length              => 13,
        bullbreese          => -13.89,
        molecular_weight    => 5503.9,
        real_retention_time => 9.45,
        cleavage            => 'tryptic',
    };

    my $orig = {
        sequence            => 'KKKKKKKKKKKK',
        length              => 13,
        bullbreese          => -13.89,
        molecular_weight    => 5503.9,
        real_retention_time => 9.45,
        cleavage            => 'tryptic',
    };

    my $combined = $util->merge_if_different($new, $orig);

    is_deeply($combined, $orig, "Returned original HashRef");
};

done_testing();
