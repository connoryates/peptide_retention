#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw/$RealBin/;
use lib "$RealBin/../lib";

use API::Elasticsearch;
use Peptide::Model;
use Data::Dumper;
use Getopt::Long;

GetOptions(
    "verbose" => \my $verbose
);

run ();

sub run {
    my $model   = Peptide::Model->new;
    my $elastic = API::Elasticsearch->new;

    my $rs = $model->schema->protein_description->search({});
    while (my $desc = $rs->next) {
        my $data = $desc->{_column_data};
        delete $data->{id};

        $data->{title} = $data->{primary_id} =~ /^.+\|.+\|(.+)$/;
        $data->{body}  = $data->{description};

        print Dumper $data if $verbose;

        $elastic->index_peptide($data);
    }
}

exit(0);
