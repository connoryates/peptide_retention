#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long;
use FindBin qw/$RealBin/;
use lib "$RealBin/../lib";

use API::Elasticsearch;

GetOptions(
    "index=s" => \my $index,
);

run();

sub run {
    my $elastic = API::Elasticsearch->new->elastic;

    $elastic->indices->create( index => $index );
}

exit(0);
