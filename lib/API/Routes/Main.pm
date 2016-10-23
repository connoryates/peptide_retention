package API::Routes::Healthcheck;

use Dancer ':syntax';

any '/healthcheck' => sub {
    return 'OK';
};

true;

=pod

=head1 any /healthcheck

Healthcheck for deployment/build purposes

=cut

1;
