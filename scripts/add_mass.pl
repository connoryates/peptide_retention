#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Peptide::Schema;
use Data::Dumper;
use Peptide::Mass;
use Getopt::Long;

GetOptions(
    peptide => \my $peptide,
    protein => \my $protein,
    all     => \my $all,
    dry_run => \my $dry_run,
);

run();

sub run {
    my $mass = Peptide::Mass->new;

    my $schema;
    if ($all) {
        if (fork()) {
            $schema = Peptide::Schema->new;
            my $peptides = $schema->peptide;
            my $rs = $peptides->search({});

            while (my $next = $rs->next) {
                my $data = $next->{_column_data};
                my $seq  = $data->{sequence};

                next unless $seq;

                if (not $data->{average_mass}) {
                    $data->{average_mass} = $mass->average_mass($seq);
                }

                if (not $data->{monoisotopic_mass}) {
                    $data->{monoisotopic_mass} = $mass->monoisotopic_mass($seq);
                }

                if ($dry_run) {
                    print Dumper $data;
                }
                else {
                    $peptides->update_or_create($data);
                }
            }
        }
        else {
            $schema = Peptide::Schema->new;
            my $pro_seq = $schema->protein_sequence;
            my $rs = $pro_seq->search({});

            while (my $next = $rs->next) {
                my $data = $next->{_column_data};
                my $seq  = $data->{sequence};

                next unless $seq;

                if (not $data->{average_mass}) {
                    $data->{average_mass} = $mass->average_mass($seq);
                }
                if (not $data->{monoisotopic_mass}) {
                    $data->{monoisotopic_mass} = $mass->monoisotopic_mass($seq);
                }

                if ($dry_run) {
                    print Dumper $data;
                }
                else {
                    $pro_seq->update_or_create($data);
                }
            }
        }
    }
}

1;

__END__
