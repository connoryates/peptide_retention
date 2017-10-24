use strict;
use warnings;

use Test::Most;

use_ok('Peptide::Util');

my $util = Peptide::Util->new;

isa_ok($util, 'Peptide::Util');

subtest 'Checking methods' => sub {
    my @methods = qw(ensure_integer);

    can_ok($util, @methods);
};

subtest 'Testing ensure integer' => sub {
    my $test = {
        key_1 => '1.1',
        key_2 => '-1.01',
        key_3 => 'foobar',
    };

    my $ret = $util->ensure_integer($test);

    is_deeply($ret, $test, 'Data structure not munged');
};

done_testing();

