use strict;
use warnings;

use Test::Most;

use_ok 'API::Controllers::Mass';

my $mass = API::Controllers::Mass->new;

isa_ok($mass, 'API::Controllers::Mass');

subtest 'Checking methods' => sub {
    my @methods = qw(find);

    can_ok($mass, @methods);
};

subtest 'Testing find' => sub {
    diag 'Testing average_mass';

    my $peptide = $mass->find({
        average => 3588.26127,
    });

    my $expect = {
        sequence            => 'LHEVTLLVDSTHIFLVHFVLAAVVINLITDNM',
        molecular_weight    => 3570.36,
        cleavage            => 'tryptic',
        real_retention_time => undef,
        length              => 32,
        monoisotopic_mass   => 3585.96323,
        average_mass        => 3588.26127,
        id                  => 375006,
        bullbreese          => '-14.36',
        confidence          => '100%',
    };

    is_deeply($peptide, $expect, 'Got correct data');


    diag 'Testing monoisotopic_mass';

    $peptide = $mass->find({
        monoisotopic => 3585.96323,
    });

    $expect = {
        sequence            => 'LHEVTLLVDSTHIFLVHFVLAAVVINLITDNM',
        molecular_weight    => 3570.36,
        cleavage            => 'tryptic',
        real_retention_time => undef,
        length              => 32,
        monoisotopic_mass   => 3585.96323,
        average_mass        => 3588.26127,
        id                  => 375006,
        bullbreese          => '-14.36',
        confidence          => '100%',
    };

    is_deeply($peptide, $expect, 'Got correct data');
};

done_testing();

