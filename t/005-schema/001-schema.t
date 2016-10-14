#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'Peptide::Schema';

my $schema = Peptide::Schema->new;

isa_ok($schema, 'Peptide::Schema');

done_testing();
