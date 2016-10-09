#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'Peptide::Retention';

my $ret = Peptide::Retention->new;

can_ok($ret, qw(tryptic_vals));

my $resp = $ret->tryptic_vals('R');

use Data::Dumper;

warn "RESP => " . Dumper $resp;

done_testing();
