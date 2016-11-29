#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw/$RealBin/;
use lib "$RealBin/../lib";

use API::Elasticsearch;
use Peptide::Model;
use Data::Dumper;

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

        $elastic->index_peptide($data);
    }
}

exit(0);
