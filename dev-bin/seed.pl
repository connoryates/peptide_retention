#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long;
use Bio::SeqIO;
use Data::Dumper;

use FindBin qw/$RealBin/;
use lib "$RealBin/../lib";

use Peptide::Model;
use Peptide::Retention;

GetOptions(
    "dry_run" => \my $dry_run,
    "seed=s"  => \my $seed,
);

warn "--dry_run option available. Kill now if you want to run a dry run first"
  unless defined $dry_run;

my $model     = Peptide::Model->new;
my $retention = Peptide::Retention->new;

run();

sub run {
    my $path  = "$RealBin/../data/seed/";
    my @files = `ls $path`;

    die 'No seed data found.' unless @files;

    foreach my $file (@files) {
        next if $file =~ /tar\.gz/;
        next unless $file =~ /$seed/;

        print "FILE => $file\n";

        $file =~ s/\n//g;

        my $seed_data = $path . $file;

        open (my $fh, "<", $seed_data) or next;

        my $stream = Bio::SeqIO->newFh(
            -format => 'Fasta',
            -fh     => $fh,
        );

        while ( my $seq  = <$stream> ) {
            my $peptide  = $seq->primary_seq->seq;
            my $desc     = $seq->primary_seq->description;
            my $protein  = $seq->primary_seq->primary_id;

            print Dumper $seq;

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
                    $model->add_retention_info($ret_info);
                }
            }
        }
    }
}

exit(0);

=pod

=head1 Usage

$ tar -xvzf data/seed/seed_data.tar.gz
$ PLACK_ENV=development perl dev-bin/seed.pl [--dry_run]

Script to seed the database with fasta files in data/raw/

=cut
