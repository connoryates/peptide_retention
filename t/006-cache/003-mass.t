use strict;
use warnings;

use Test::Most;

use_ok('API::Cache');
use_ok('API::Cache::Mass');

my $cache      = API::Cache->new;
my $mass_cache = API::Cache::Mass->new;
my $mass       = $cache->_create_uuid;

my $payload = {
    peptide => {
        foo  => 'bar',
        bat  => 'baz',
    },
    mass => $mass,
};

isa_ok($cache, 'API::Cache');
isa_ok($mass_cache, 'API::Cache', 'API::Cache::Mass');

subtest 'Checking methods' => sub {
    my @methods = qw(get_mass_cache set_mass_cache);

    can_ok($cache, @methods);
};

subtest 'Testing set_mass_cache' => sub {
    is(1, $cache->set_mass_cache($payload), 'Set cache correctly');

    my $data = $cache->get_mass_cache($mass);

    is_deeply($data, $payload, 'Retrieved correct data');
};

done_testing();

