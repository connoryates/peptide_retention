#!/usr/bin/env perl
use strict;
use warnings;

use Getopt::Long;
use FindBin qw/$RealBin/;
use lib "$RealBin/../lib";

use Data::Dumper;
use Peptide::Correlation;

GetOptions(
    "type=s" => \my $type,
);

die "USAGE: missing required param : type" unless defined $type;

my $corr        = Peptide::Correlation->new( type => $type );
my $correlation = $corr->correlate_retention_datasets;

print "$correlation\n";

1;
