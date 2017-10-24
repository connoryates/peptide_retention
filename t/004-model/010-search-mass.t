use strict;
use warnings;

use Test::Most;

use_ok 'Peptide::Model';

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

subtest 'Checking methods' => sub {
    my @methods = qw(search_mass);

    can_ok($model, @methods);
};

subtest 'Testing search_mass' => sub {
    diag 'Testing average_mass';

    my $peptide = $model->search_mass({
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
        confidence          => '100%'
    };

    is_deeply($peptide, $expect, 'Got correct data');


    diag 'Testing monoisotopic_mass';

    $peptide = $model->search_mass({
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

subtest 'Testing _heuristic_search' => sub {
    diag 'Testing monoisotopic_mass';

    my $peptide = $model->_heuristic_search({
        mass_type => 'monoisotopic_mass',
        mass      => 3588.26125,
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
        confidence          => '100%'
    };

    is_deeply($peptide, $expect, 'Got correct data');


    diag 'Testing average_mass';

    $peptide = $model->_heuristic_search({
        mass_type => 'average_mass',
        mass      => 3585.95323,
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

