use strict;
use warnings;

use Test::Most;

use_ok('Peptide::Model');

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

subtest 'Checking methods' => sub {
    my @methods = qw(get_all_peptides);

    can_ok($model, @methods);
};

subtest 'Testing get_all_proteins' => sub {
    my $peptides = $model->get_all_peptides({
        length => 27,
    });

    use Data::Dumper;
    print Dumper $peptides;
};

done_testing();

