use strict;
use warnings;

use Test::Most;

use_ok('Peptide::Model');

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

subtest 'Checking methods' => sub {
    my @methods = qw(search_peptides _format_search _format_search_exec);

    can_ok($model, @methods);
};

subtest 'Testing _format_search' => sub {
    diag 'Testing with primary_ids';

    my $results = $model->_format_search({
        primary_ids => ['Reverse_sp|P50108|MNN10_YEAST'],
    });

    my $expect = <<EXPECT;
    SELECT
        ps.sequence as protein_sequence,
        pr.algorithm,
        p.molecular_weight,
        pr.predicted_time,
        p.length,
        p.sequence,
        p.bullbreese,
        p.real_retention_time,
        p.cleavage,
        ps.primary_id
    FROM peptides p
            JOIN predictions pr
                ON pr.peptide_id = p.id
            JOIN proteins pro
                ON pro.peptide_id = p.id
            JOIN protein_sequences ps
                ON ps.id = pro.sequence_id
                    WHERE EXISTS (SELECT id FROM protein_sequences WHERE primary_id IN ( ?))
EXPECT

    chomp($expect);

    is($results, $expect, "Got correct SQL for primary_ids");


    diag 'Testing with primary_ids and length';

    $results = $model->_format_search({
        primary_ids => ['Reverse_sp|P50108|MNN10_YEAST'],
        length      => 17,
    });

    $expect = <<EXPECT;
    SELECT
        ps.sequence as protein_sequence,
        pr.algorithm,
        p.molecular_weight,
        pr.predicted_time,
        p.length,
        p.sequence,
        p.bullbreese,
        p.real_retention_time,
        p.cleavage,
        ps.primary_id
    FROM peptides p
            JOIN predictions pr
                ON pr.peptide_id = p.id
            JOIN proteins pro
                ON pro.peptide_id = p.id
            JOIN protein_sequences ps
                ON ps.id = pro.sequence_id
                    WHERE EXISTS (SELECT id FROM protein_sequences WHERE primary_id IN ( ?)) AND p.length = ?
EXPECT

    chomp($expect);

    is($results, $expect, "Got correct SQL for primary_ids and length");


    diag 'Testing with primary_ids, length, and limit';

    $results = $model->_format_search({
        primary_ids => ['Reverse_sp|P50108|MNN10_YEAST'],
        length      => 17,
        limit       => 100,
    });

    $expect = <<EXPECT;
    SELECT
        ps.sequence as protein_sequence,
        pr.algorithm,
        p.molecular_weight,
        pr.predicted_time,
        p.length,
        p.sequence,
        p.bullbreese,
        p.real_retention_time,
        p.cleavage,
        ps.primary_id
    FROM peptides p
            JOIN predictions pr
                ON pr.peptide_id = p.id
            JOIN proteins pro
                ON pro.peptide_id = p.id
            JOIN protein_sequences ps
                ON ps.id = pro.sequence_id
                    WHERE EXISTS (SELECT id FROM protein_sequences WHERE primary_id IN ( ?)) AND p.length = ? LIMIT 100
EXPECT

    chomp($expect);

    is($results, $expect, "Got correct SQL for primary_ids and length");


    diag 'Testing with primary_ids, length, limit, and offset';

    $results = $model->_format_search({
        primary_ids => ['Reverse_sp|P50108|MNN10_YEAST'],
        length      => 17,
        limit       => 100,
        offset      => 100,
    });

    $expect = <<EXPECT;
    SELECT
        ps.sequence as protein_sequence,
        pr.algorithm,
        p.molecular_weight,
        pr.predicted_time,
        p.length,
        p.sequence,
        p.bullbreese,
        p.real_retention_time,
        p.cleavage,
        ps.primary_id
    FROM peptides p
            JOIN predictions pr
                ON pr.peptide_id = p.id
            JOIN proteins pro
                ON pro.peptide_id = p.id
            JOIN protein_sequences ps
                ON ps.id = pro.sequence_id
                    WHERE EXISTS (SELECT id FROM protein_sequences WHERE primary_id IN ( ?)) AND p.length = ? OFFSET 100 LIMIT 100
EXPECT

    chomp($expect);

    is($results, $expect, "Got correct SQL for primary_ids and length");
};

subtest _format_search_exec => sub {
    diag 'Formatting search values with primary_ids';

    my $results = $model->_format_search_exec({
        primary_ids => ['Reverse_sp|P50108|MNN10_YEAST'],
    });

    my $expect = ['Reverse_sp|P50108|MNN10_YEAST'];

    is_deeply($results, $expect, 'Got correct search values');


    diag 'Formatting search values with primary_ids and length';

    $results = $model->_format_search_exec({
        primary_ids => ['Reverse_sp|P50108|MNN10_YEAST'],
        length      => 17
    });

    $expect = ['Reverse_sp|P50108|MNN10_YEAST', 17];

    is_deeply($results, $expect, 'Got correct search values');
};

subtest search_peptides => sub {
    diag 'Testing search with keywords';

    my $results = $model->search_peptides({
        keywords => 'mannosyltransferase',
        limit    => 100,
    });

    isa_ok($results, 'ARRAY');
};

done_testing();

