package API::Routes::Peptides;

use Dancer ':syntax';
use Dancer::Exception qw(:all);
use Dancer::Plugin::Res;
use API::Plugins::Peptides;
use API::Plugins::KeyManager;
use API::X;

set serializer => 'JSON';

hook 'before' => sub {
    var 'authorized' => 1;

    return 1;
};

post '/api/v1/retention/peptide/info' => sub {
    my $params = params || {};

    my $authorized = var 'authorized';

    API::X->throw({
        message => "Unauthorized",
        code    => 401,
    }) unless $authorized;

    API::X->throw({
        message => "Missing required param : peptide",
        code    => 500,
    }) unless defined $params->{peptide};

    my $data;
    try {
        my $peptide_manager = peptide_manager();
           $data = $peptide_manager->retention_info($params->{peptide});
    } catch {
        API::X->throw({
            message => "Failed to get retention info : $_",
            code    =>  500,
        });
    };

    return res 200, $data;
};

post '/api/v1/retention/peptide/add' => sub {
    my $params = params || {};

    my $authorized = var 'authorized';

    API::X->throw({
        message => "Unauthorized",
        code    => 401
    }) unless defined $authorized;

    foreach my $required (qw(peptide retention_time prediciton_algorithm)) {
        API::X->throw({
            message => "Missing param : $required",
            code    => 500
        }) unless $params->{$required};
    }

    $params->{retention_info}->{prediction_info} = $params->{prediciton_algorithm};

    my $status;
    try {
        my $peptide_manager = peptide_manager();
           $status = $peptide_manager->add_retention_info($params);
    } catch {
        API::X->throw({
            message => "Failed to add retention info : $_",
            code    => 500
        });
    };

    return res 200, $status;
};

true;

=pod

=head1

post /api/v1/retention/peptide/info

Accepts parameters:

    { peptide => $peptide }

Returns:

     {
         "retention_info" : {
            "peptide" : "K",
            "predicted_retention" : -2.1,
            "prediction_algorithm" : "hodges",
            "bullbreese" : 0.46
         }
     }

=head2 post /api/v1/retention/peptide/add

NOTE: Need to adjust database schema to accept method param

Accepts parameters:

    {
        peptide              => $peptide,
        retention_time       => $retention_time, 
        prediciton_algorithm => $prediciton_algorithm,
    }

Returns:

    HTTP Status

=cut

1;
