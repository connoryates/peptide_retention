#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Test::Exception;

use_ok 'Peptide::MolecularWeight';

my $mw = Peptide::MolecularWeight->new;

isa_ok($mw, 'Peptide::MolecularWeight');

subtest 'Checking methods' => sub {
    my @methods = qw(assign_molecular_weight);

   can_ok($mw, @methods);
};

subtest 'Testing assign_molecular_weight' => sub {
    my $weight = $mw->assign_molecular_weight('K');

    is($weight, 128.17, "Got correct molecular weight for K");
};

subtest 'Testing exceptions' => sub {
    throws_ok { $mw->assign_molecular_weight(undef) } qr/Missing required param/,      "Caught missing arg 1";
    throws_ok { $mw->assign_molecular_weight('X')   } qr/X is not a valid amino acid/, "Caught non amino acid";
};

done_testing();
