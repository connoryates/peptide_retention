#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;
use Test::Exception;

use_ok 'Peptide::Model';

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

subtest 'Checking methods' => sub {
    my @methods = qw(get_associated_proteins);

    can_ok($model, @methods);
};

subtest 'Testing get_associated_proteins' => sub {
    my $proteins = $model->get_associated_proteins('GIITSTVDWKPIK');

    my $expect = {
        proteins => [
            {
                sequence_id => 1,
                id          => 7,
                protein_sequences  => [
                    {
                        primary_id => 'sp|P53266|SHY1_YEAST',
                        sequence   => 'MSLLGARSTYRWFSIAASIPTKNAIGKSTYLLASRNQQYRGIITSTVDWKPIKTGKSPNDDSRRERSFGKKIVLGLMFAMPIISFYLGTWQVRRLKWKTKLIAACETKLTYEPIPLPKSFTPDMCEDWEYRKVILTGHFLHNEEMFVGPRKKNGEKGYFLFTPFIRDDTGEKVLIERGWISEEKVAPDSRNLHHLSLPQEEHLKVVCLVRPPKKRGSLQWAKKDPNSRLWQVPDIYDMARSSGCTPIQFQALYDMKDHPIIEEHTRNEASQNNSTSSLWKFWKREPTTAVNGTQAVDNNTSKPRSRQEMPTDQTIEFDERQFIKAGVPIGRKPTIDLKNNHLQYLVTWYGLSFLSTIFLIVALRKAKRGGVVSQDQLMKEKLKHSRKYM',
                        protein_descriptions => [
                            {
                                primary_id  => 'sp|P53266|SHY1_YEAST',
                                description => 'Cytochrome oxidase assembly protein SHY1 OS=Saccharomyces cerevisiae (strain ATCC 204508 / S288c) GN=SHY1 PE=1 SV=1',
                                id => 1
                            }
                        ],
                        id => 1
                    }
                ],
                peptide_id => 7
            }
        ],
        bullbreese          => -3.13,
        length              => 13,
        real_retention_time => undef,
        sequence            => 'GIITSTVDWKPIK',
        cleavage            => 'tryptic',
        molecular_weight    => 1438.66,
        id                  => 7
    };

    is_deeply($proteins, $expect, "Got expected associated proteins");
};

done_testing();
