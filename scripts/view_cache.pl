#!/usr/bin/env perl
use strict;
use warnings;

use FindBin qw/$RealBin/;
use lib "$RealBin/../lib";

use API::Cache::Correlate;
use API::Cache::Peptide;
use Getopt::Long;
use Data::Dumper;

GetOptions(
    "namespace=s" => \my $namespace,
);

die "USAGE: no namespace specified" unless defined $namespace;

if ($namespace eq 'correlate') {
    my $cache = API::Cache::Correlate->new;
    my @keys  = $cache->chi->get_keys();

    foreach my $key (@keys) {
        print Dumper $cache->chi->get($key);
    }
}
elsif ($namespace eq 'peptide') {
    my $cache = API::Cache::Peptide->new;
    my @keys  = $cache->chi->get_keys();

    foreach my $key (@keys) {
        print Dumper $cache->chi->get($key);
    }
}
elsif ($namespace eq 'mass') {
    my $cache = API::Cache::Mass->new;
    my @keys  = $cache->chi->get_keys();

    foreach my $key (@keys) {
        print Dumper $cache->chi->get($key);
    }
}
else {
    die "Invalid namespace";
}

exit(0);

