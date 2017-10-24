use strict;
use warnings;

use Test::Most;

use_ok('Peptide::Model');

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

subtest 'Checking methods' => sub {
    my @methods = qw(get_count get_protein_count get_peptide_count);

    can_ok($model, @methods);
};

subtest 'Testing get_counts' => sub {
    my $peptide_count = $model->get_peptide_count;
    my $expect        = $model->get_count('peptide');

    like($peptide_count, qr/\d+/, 'Got a number from peptide count');
    like($peptide_count, qr/\d+/, 'Got a number from peptide count');
    is_deeply($peptide_count, $expect, 'Got expected peptide count');

    my $protein_count = $model->get_peptide_count;
       $expect        = $model->get_count('peptide');

    like($protein_count, qr/\d+/, 'Got a number from protein count');
    like($protein_count, qr/\d+/, 'Got a number from protein count');
    is_deeply($protein_count, $expect, 'Got expected protein count');
};

done_testing();

