#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'Peptide::Util';

my $util = Peptide::Util->new;

isa_ok($util, 'Peptide::Util');

subtest 'Checking methods' => sub {
    my @methods = qw(hash_merge);

    can_ok($util, @methods);
};

subtest 'Testing hash_merge' => sub {
    my $test_1 = {
        foo => 'bar',
        bat => 'baz',
    };

    my $test_2 = {
        qux  => 'blorgle',
        blah => 'bloo',
        foo  => 'baz',
    };

    my $expect = {
        foo => 'bar',
        bat => 'baz',
        qux  => 'blorgle',
        blah => 'bloo',
    };

    my $combined = $util->hash_merge($test_1, $test_2);

    is_deeply($combined, $expect, "Got expected merged hash structure");
};

done_testing();
