use strict;
use warnings;

use Test::Most;

use_ok('Peptide::Mass');

my $mass = Peptide::Mass->new;

isa_ok($mass, 'Peptide::Mass');

subtest 'Checking methods' => sub {
    my @methods = qw(average_mass);

    can_ok($mass, @methods);
};

subtest 'Testing average_mass' => sub {
    my $sequence = 'MSLLGARSTYRWFSIAASIPTKNAIGKSTYLLASRNQQYRGIITSTVDWKPIKTGKSPNDDSRRERSFGKKIVLGLMFAMPIISFYLGTWQVRRLKWKTKLIAACETKLTYEPIPLPKSFTPDMCEDWEYRKVILTGHFLHNEEMFVGPRKKNGEKGYFLFTPFIRDDTGEKVLIERGWISEEKVAPDSRNLHHLSLPQEEHLKVVCLVRPPKKRGSLQWAKKDPNSRLWQVPDIYDMARSSGCTPIQFQALYDMKDHPIIEEHTRNEASQNNSTSSLWKFWKREPTTAVNGTQAVDNNTSKPRSRQEMPTDQTIEFDERQFIKAGVPIGRKPTIDLKNNHLQYLVTWYGLSFLSTIFLIVALRKAKRGGVVSQDQLMKEKLKHSRKYM';

    my $avg = $mass->monoisotopic_mass($sequence);
    is($avg, 45027.46854, 'Got expected avg mass');

    $avg = $mass->average_mass($sequence);
    is($avg, 45055.98336, 'Got expected avg mass');
};

done_testing();

