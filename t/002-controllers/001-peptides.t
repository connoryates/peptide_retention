#!/usr/bin/env perl
use strict;
use warnings;

use Test::Most;

use_ok 'API::Controllers::Peptides';

my $controller = API::Controllers::Peptides->new;

isa_ok($controller, 'API::Controllers::Peptides');

subtest 'Checking methods' => sub {
    my @methods = qw(retention_info add_retention_info search next);

    can_ok($controller, @methods);
};

subtest 'Testing search and next' => sub {
    diag 'Testing with limit but no offset';

    my $args = {
        length   => 17,
        keywords => 'mannosyltransferase',
        limit    => 100,
    };

    my $results = $controller->search($args);

    isa_ok($results, 'HASH');


    diag 'Testing with limit and offset';

    $args = {
        length   => 17,
        keywords => 'mannosyltransferase',
        limit    => 100,
        offset   => 100,
    };

    $results = $controller->search($args);

    isa_ok($results, 'HASH');


    diag 'Testing next';

    my $uuid_regexp = qr/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/;

    my $next = $results->{next};
    like($next, $uuid_regexp, 'Got a uuid back as next key');

    my $next_results = $controller->next($next);
    isa_ok($next_results, 'HASH', 'Got a HASH back from next');
};

subtest 'Testing counts' => sub {
    diag 'Testing counts';

    my $counts = $controller->counts;

    like($counts->{total_proteins}, qr/\d+/, 'Got number back from total_proteins');
    like($counts->{total_peptides}, qr/\d+/, 'Got number back from total_peptides');
};

done_testing();
