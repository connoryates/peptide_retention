package API::Routes::Peptides;

use Dancer ':syntax';
use Dancer::Exception qw(:all);
use Dancer::Plugin::Res;
use API::Plugins::Peptides;
use API::Plugins::KeyManager;

set serializer => 'JSON';

hook 'before' => sub {
    var 'authorized' => 1;

    return 1;
};

post '/api/v1/retention/peptide/info' => sub {
    my $params = params || {};

    my $authorized = var 'authorized';

    send_error("Unauthorized", 401) unless defined $authorized;
    send_error("Missing param : peptide", 500) unless defined $params->{peptide};

    my $data;
    try {
        my $peptide_manager = peptide_manager();
           $data = $peptide_manager->retention_info($params->{peptide});
    } catch {
        send_error("Something went wrong", 500);
    };

    return res 200, $data;
};

post '/api/v1/retention/peptide/add' => sub {
    my $params = params || {};

    my $authorized = var 'authorized';

    send_error("Unauthorized", 401) unless defined $authorized;

    foreach my $required (qw(peptide retention_time)) {
        send_error("Missing param : $required", 500) unless defined $params->{$required};
    }

    my $status;
    try {
        my $peptide_manager = peptide_manager();
           $status = $peptide_manager->add_retention_info($params);
    } catch {
        send_error("Something went wrong", 500);
    };

    return res 200, $status;
};

true;
