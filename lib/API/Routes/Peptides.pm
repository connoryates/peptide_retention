package API::Routes::Peptides;

use Dancer ':syntax';
use Dancer::Exception;
use API::Plugins::Peptides;
use API::Plugins::KeyManager;
use JSON::XS qw(encode_json);

hook 'before' => sub {
    return 1;
};

post '/api/v1/retention/peptide/info' => sub {
    my $params = params || {};

    my $authorized = var 'authorized';

    send_error("Unauthorized" => 401) unless defined $authorized;

    send_error("Missing param : peptide" => 500) unless defined $params->{peptide};

    my $data;
    try {
        my $peptide_manager = peptide_manager();
           $data = $peptide->retention_info($params->{peptide});
    } catch {
        send_error("Something went wrong" => 500);
    };

    return encode_json($data);
}

post '/api/v1/retention/peptide/add' => sub {
    my $params = params || {};

    my $authorized = var 'authorized';

    send_error("Unauthorized" => 401) unless defined $authorized;

    foreach my $required (qw(peptide retention_time)) {
        send_error("Missing param : $required" => 500) unless defined $params->{$required};
    }

    my $status;
    try {
        my $peptide_manager = peptide_manager();
           $status = $peptide->add_retention_info($params);
    } catch {
        send_error("Something went wrong" => 500);
    };

    return status;
};

true;
