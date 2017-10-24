use strict;
use warnings;

use Test::Most;
use Scalar::Util qw(looks_like_number);

use_ok('Peptide::Model');

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

subtest 'Checking methods' => sub {
    my @methods = qw(correlate_data);

    can_ok($model, @methods);
};

subtest 'Testing correlate' => sub {
    plan skip_all => 'Skipping correlate test.' unless $ENV{CORRELATE_TESTS};

    diag('Testing with no length requirements (this may take a while)');

    my $corr = $model->correlate_data({
        filter => {
            algorithm => 'hodges',
        }
    });

    diag "Correlation => $corr";
    is(looks_like_number($corr), 1, 'Got a number back from correlation');


    diag('Testing with length requirements (this may take a while)');

    $corr = $model->correlate_data({
        filter => {
            algorithm => 'hodges',
            length    => 7,
        }
    });

    diag "Correlation => $corr";
    is(looks_like_number($corr), 1, 'Got a number back from correlation');
};

done_testing();

