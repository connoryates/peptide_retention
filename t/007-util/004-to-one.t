use strict;
use warnings;

use Test::Most;

use_ok('Peptide::Util');

my $util = Peptide::Util->new;

isa_ok($util, 'Peptide::Util');

subtest 'Checking methods' => sub {
    my @methods = qw(to_one);

    can_ok($util, @methods);
};

subtest 'Testing to_one' => sub {
    my $test = 0.0001;
    my $one = $util->to_one($test);

    is($one, 1, "Got 1 from $test");


    $test = 0.001;
    $one = $util->to_one($test);

    is($one, 1, "Got 1 from $test");


    $test = 0.01;
    $one = $util->to_one($test);

    is($one, 1, "Got 1 from $test");


    $test = 0.1;
    $one = $util->to_one($test);

    is($one, 1, "Got 1 from $test");
};

done_testing();
