#!/usr/bin/env perl
use strict;
use warnings;

use Mesoderm;
use SQL::Translator;
use DBI;

my $dsn  = "DBI:Pg:dbname=yeast;host=127.0.0.1;port=5432";
my $user = "peptide";
my $pass = "powerhouse7";


my $dbh = DBI->connect($dsn, $user, $pass);

my $sqlt = SQL::Translator->new(dbh => $dbh, from => 'DBI');
$sqlt->parse(undef);

my $scaffold = Mesoderm->new(
    schema       => $sqlt->schema,
    schema_class => 'Peptide::Schema',
);

$scaffold->produce(\*STDOUT);

1;
