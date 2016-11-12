#!/usr/bin/env perl
use strict;
use warnings;

use Test::Exception;
use Test::Most;
use Data::Dumper;

use_ok 'Peptide::Model';

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

subtest 'Checking methods' => sub {
    my @methods = qw(get_retention_info _get_retention_info);

    can_ok($model, @methods);
};

subtest 'Testing get_retention_info' => sub {
    my $result = $model->get_retention_info('GIITSTVDWKPIK');

    my $expect = {
        molecular_weight => '1438.66',
        length           => 13,
        proteins => [
            {
                protein_sequences => [
                    {
                        protein_descriptions => [
                            {
                                description => 'Cytochrome oxidase assembly protein SHY1 OS=Saccharomyces cerevisiae (strain ATCC 204508 / S288c) GN=SHY1 PE=1 SV=1',
                                primary_id  => 'sp|P53266|SHY1_YEAST',
                                id          => 1
                            }
                        ],
                        sequence    => 'MSLLGARSTYRWFSIAASIPTKNAIGKSTYLLASRNQQYRGIITSTVDWKPIKTGKSPNDDSRRERSFGKKIVLGLMFAMPIISFYLGTWQVRRLKWKTKLIAACETKLTYEPIPLPKSFTPDMCEDWEYRKVILTGHFLHNEEMFVGPRKKNGEKGYFLFTPFIRDDTGEKVLIERGWISEEKVAPDSRNLHHLSLPQEEHLKVVCLVRPPKKRGSLQWAKKDPNSRLWQVPDIYDMARSSGCTPIQFQALYDMKDHPIIEEHTRNEASQNNSTSSLWKFWKREPTTAVNGTQAVDNNTSKPRSRQEMPTDQTIEFDERQFIKAGVPIGRKPTIDLKNNHLQYLVTWYGLSFLSTIFLIVALRKAKRGGVVSQDQLMKEKLKHSRKYM',
                        id         => 1,
                        primary_id => 'sp|P53266|SHY1_YEAST'
                     }
                 ],
                 sequence_id => 1,
                 peptide_id  => 7,
                 id          => 7
             }
         ],
         real_retention_time => undef,
         predictions => [
             {
                 id             => 7,
                 predicted_time => 34.8,
                 peptide_id     => 7,
                 algorithm      => 'hodges'
             }
         ],
         bullbreese => -3.13,
         id         => 7,
         cleavage   => 'tryptic',
         sequence   => 'GIITSTVDWKPIK'
    };

    is_deeply($result, $expect, "Got expected results from get_retention_info");
};

subtest 'Testing _get_retention_info' => sub {
    my $result = $model->_get_retention_info('GGGGGGGGGGGGGGGGGGGGGGR');

    my $expect = {
        predicition_info => [
             {
                 predicted_time => -5,
                 algorithm      => 'hodges'
             }
        ],
      retention_info => {
            cleavage         => 'tryptic',
            molecular_weight => '1271.29',
            sequence         => 'GGGGGGGGGGGGGGGGGGGGGGR',
            length           => 23,
            bullbreese       => 18.51
        }
    };

    is_deeply($result, $expect, "Got expected results from _get_retention_info");
};

done_testing();
