use strict;
use warnings;

use FindBin qw/$RealBin/;
use Data::Dumper;
use Test::Most;

use_ok('Peptide::Model');

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

my $file = "$RealBin/../../data/mass/001.txt";

my $data;
{
    local $/ = undef;
    open my $fh, '<', $file or die $!;
    $data = <$fh>;
    close $fh;
};

my @mass = split /\n/, $data;

subtest 'Searching mass values' => sub {
    test_search(\@mass);
    is(1, 1);
};

subtest 'Searching heuristic values' => sub {
    $model->heuristic(1);

    test_search(\@mass);
    is(1, 1);
};

sub test_search {
    my $list = shift;

    foreach my $mass (@$list) {
        print 'MASS => ' . Dumper $mass;
        my $result = $model->search_mass({
            average => $mass,
        });

        print 'RESULT => ' . Dumper $result;
    }
}

done_testing();

