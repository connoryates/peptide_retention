#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Test::Exception;

use_ok 'Peptide::Util';

my $util = Peptide::Util->new;

isa_ok($util, 'Peptide::Util');

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

subtest 'Checking methods' => sub {
    my @methods = qw(hash_merge);

    can_ok($util, @methods);
};

subtest 'Testing hash_merge' => sub {
    my $combined = $util->hash_merge($test_1, $test_2);

    is_deeply($combined, $expect, "Got expected merged hash structure");
};

subtest 'Testing exceptions' => sub {
    throws_ok { $util->hash_merge(undef, $test_2)    } qr/Two HashRefs must be provided/, 'Caught exception for missing arg 1';
    throws_ok { $util->hash_merge($test_1, undef)    } qr/Two HashRefs must be provided/, 'Caught exception for missing arg 2';
    throws_ok { $util->hash_merge(%$test_1, $test_2) } qr/Argument 1 must be a HashRef/,  'Caught exception for non HashRef arg 1';
    throws_ok { $util->hash_merge($test_1, %$test_2) } qr/Argument 2 must be a HashRef/,  'Caught exception for non HashRef arg 2';
    throws_ok { $util->hash_merge([], [])            } qr/Argument 1 must be a HashRef/,  'Caught exception for non HashRef arg 1';
};

done_testing();
