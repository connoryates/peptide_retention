#!/usr/bin/env perl
use strict;
use warnings;

use Data::Dumper;
use Test::Most;

use_ok 'Peptide::Schema';

my $schema  = Peptide::Schema->new;

my $peptide = $schema->peptide;

$peptide->result_class('DBIx::Class::ResultClass::HashRefInflator');

my $results = $peptide->find(
    {
        sequence => 'MSLLGAR',
    },
    {
        prefetch => [
            'proteins',
            'predictions',
            { 
                proteins => { protein_sequences => 'protein_descriptions' },
            },
        ],
    },
);

print Dumper $results;

done_testing();
