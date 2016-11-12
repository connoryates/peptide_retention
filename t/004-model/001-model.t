#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'Peptide::Model';

my $model = Peptide::Model->new;

isa_ok($model, 'Peptide::Model');

subtest 'Checking methods' => sub {
    my @methods = qw(
        add_retention_info _get_retention_info
        add_retention_info get_bb_retention_correlation_data
        get_peptide_retention_correlation_data
        get_peptide_retention_filtered_data
        _peptide_length_filter get_bar_chart_peptide_data
        validate_api_key
    );

    can_ok($model, @methods);
};

subtest 'Testing get_retention_info' => sub {
    my $ret_info = $model->get_retention_info('GIITSTVDWKPIK');

    my $expect = {
        bullbreese  => -3.13,
        predictions => [
            {
                id             => 7,
                predicted_time => 34.8,
                peptide_id     => 7,
                algorithm      => 'hodges'
            }
        ],
        id => 7,
        real_retention_time => undef,
        proteins => [
            {
                id          => 7,
                peptide_id  => 7,
                sequence_id => 1,
                protein_sequences => [
                    {
                         primary_id => 'sp|P53266|SHY1_YEAST',
                         sequence   => 'MSLLGARSTYRWFSIAASIPTKNAIGKSTYLLASRNQQYRGIITSTVDWKPIKTGKSPNDDSRRERSFGKKIVLGLMFAMPIISFYLGTWQVRRLKWKTKLIAACETKLTYEPIPLPKSFTPDMCEDWEYRKVILTGHFLHNEEMFVGPRKKNGEKGYFLFTPFIRDDTGEKVLIERGWISEEKVAPDSRNLHHLSLPQEEHLKVVCLVRPPKKRGSLQWAKKDPNSRLWQVPDIYDMARSSGCTPIQFQALYDMKDHPIIEEHTRNEASQNNSTSSLWKFWKREPTTAVNGTQAVDNNTSKPRSRQEMPTDQTIEFDERQFIKAGVPIGRKPTIDLKNNHLQYLVTWYGLSFLSTIFLIVALRKAKRGGVVSQDQLMKEKLKHSRKYM',
                         id => 1,
                         protein_descriptions => [
                             {
                                  description => 'Cytochrome oxidase assembly protein SHY1 OS=Saccharomyces cerevisiae (strain ATCC 204508 / S288c) GN=SHY1 PE=1 SV=1',
                                  id          => 1,
                                  primary_id  => 'sp|P53266|SHY1_YEAST'
                             }
                         ]
                     }
                 ]
             }
        ],
        molecular_weight => 1438.66,
        sequence         => 'GIITSTVDWKPIK',
        cleavage         => 'tryptic',
        length           => 13
    };

    is_deeply($ret_info, $expect, "get_retention_info successful");
};

subtest 'Testing _get_retention_info' => sub {
    my $expect = {
        length               => 13,
        bullbreese           => -3.13,
        sequence             => 'GIITSTVDWKPIK',
        id                   => 7,
        real_retention_time  => undef,
        cleavage             => 'tryptic',
        predictions => [
            {
                algorithm      => 'hodges',
                id             => 7,
                predicted_time => 34.8,
                peptide_id     => 7
            }
        ],
        proteins => [
            {
                peptide_id => 7,
                protein_sequences => [
                    {
                        primary_id => 'sp|P53266|SHY1_YEAST',
                        protein_descriptions => [
                             {
                                 description => 'Cytochrome oxidase assembly protein SHY1 OS=Saccharomyces cerevisiae (strain ATCC 204508 / S288c) GN=SHY1 PE=1 SV=1',
                                 id          => 1,
                                 primary_id  => 'sp|P53266|SHY1_YEAST'
                             }
                         ],
                         id       => 1,
                         sequence => 'MSLLGARSTYRWFSIAASIPTKNAIGKSTYLLASRNQQYRGIITSTVDWKPIKTGKSPNDDSRRERSFGKKIVLGLMFAMPIISFYLGTWQVRRLKWKTKLIAACETKLTYEPIPLPKSFTPDMCEDWEYRKVILTGHFLHNEEMFVGPRKKNGEKGYFLFTPFIRDDTGEKVLIERGWISEEKVAPDSRNLHHLSLPQEEHLKVVCLVRPPKKRGSLQWAKKDPNSRLWQVPDIYDMARSSGCTPIQFQALYDMKDHPIIEEHTRNEASQNNSTSSLWKFWKREPTTAVNGTQAVDNNTSKPRSRQEMPTDQTIEFDERQFIKAGVPIGRKPTIDLKNNHLQYLVTWYGLSFLSTIFLIVALRKAKRGGVVSQDQLMKEKLKHSRKYM'
                     }
                ],
                id          => 7,
                sequence_id => 1
            }
        ],
        molecular_weight => 1438.66
    };

    my $ret_info = $model->_get_retention_info('GIITSTVDWKPIK');

    is_deeply($ret_info, $expect, "_get_retention_info successful");
};

done_testing();
