#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Try::Tiny;
use WWW::Mechanize;
use Peptide::Model;
use Bio::SeqIO;
use Data::Dumper;
use Peptide::Retention;
use Getopt::Long;

GetOptions(
    "dry_run" => \my $dry_run,
);

my $model     = Peptide::Model->new;
my $retention = Peptide::Retention->new;

run();

sub run {
    my $mech  = WWW::Mechanize->new(
        auto_check => 0,
    );

#    $mech->cookie_jar({});
#    $mech->proxy([qw(http https)] => 'socks://localhost:9050') or die "cannot use socks proxy";

    my $num   = 'P02344';

    while (1) {
        my $url = 'http://www.uniprot.org/uniprot/' . $num . '.fasta';

        try {
            $mech->get($url);
        } catch {
            $num++;
            next;
        };

        my $fasta  = $mech->content;
        my $seq_io = Bio::SeqIO->new(
            -string => $fasta,
            -format => 'Fasta'
        );

        while (my $seq = $seq_io->next_seq) {
            print Dumper $seq;
            my $peptide  = $seq->primary_seq->seq;

            if ($peptide =~ /B|Z/) {
                my $copy = $peptide;

                $copy =~ s/B/R/g;
                $copy =~ s/Z/G/g;

                add($copy, $seq);

                $peptide =~ s/B/N/g;
                $peptide =~ s/Z/E/g;

                add($peptide, $seq);
            }
            else {
                add($peptide, $seq);
            }
        }

        my $rand = int(rand(20));        

        sleep $rand;

        $num++;
    }
}

sub add {
    my ($peptide, $seq) = @_;

    my $desc     = $seq->primary_seq->description;
    my $protein  = $seq->primary_seq->primary_id;

    my $tryptic  = $retention->tryptic($peptide);

    foreach my $t (@$tryptic) {
        my $ret_info = $retention->tryptic_vals($t);

        $ret_info->{protein_info} = {
            primary_id  => $protein,
            description => $desc,
            sequence    => $peptide,
        };

        if ($dry_run) {
            print Dumper $ret_info;
        } else {
            try {
                $model->add_retention_info($ret_info);
            } catch {
                warn "Failed to add $_",
            };
        }
    }
}
