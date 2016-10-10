#!/usr/bin/env perl
use strict;
use warnings;

use Mesoderm;
use SQL::Translator;
use DBI;

use FindBin qw/$RealBin/;
use lib "$RealBin/../lib";

use Peptide::Config;

my $config = Peptide::Config->new->config->{database};

my $dbh = DBI->connect($config->{pg}->{dsn}, $config->{pg}->{user}, $config->{pg}->{pass});

my $sqlt = SQL::Translator->new(parser_args => { dbh => $dbh }, from => 'DBI');
$sqlt->parse(undef);

my $scaffold = Mesoderm->new(
    schema       => $sqlt->schema,
    schema_class => 'Peptide::Schema',
);

my $schema_file = "$RealBin/../lib/Peptide/Schema/_scaffold.pm";

open (my $fh, ">", $schema_file) or die "Cannot open schema file : $!";

$scaffold->produce($fh);

1;
