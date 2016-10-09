package API::Routes::Healthcheck;

use Dancer ':syntax';

any '/healthcheck' => sub {
    return 'OK';
};

true;
