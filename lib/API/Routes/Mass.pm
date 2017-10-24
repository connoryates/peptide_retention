package API::Routes::Mass;

use API::X;
use Dancer ':syntax';
use Dancer::Exception qw(:all);
use API::Plugins::MassManager;
use API::Plugins::KeyManager;
use Dancer::Plugin::Res;

set serializer => 'JSON';

hook before => sub {
    var authorized => 1;

    return 1;
};

get '/api/v1/mass/:mass' => sub {
    my $authorized = var 'authorized';

    API::X->throw({
        message => 'Unauthorized',
        code    => 401,
    }) unless $authorized;

    my $mass      = param 'mass';
    my $mass_type = var 'mass_type';

    $mass_type ||= 'monoisotopic';

    API::X->throw({
        message => "Missing required param : mass",
        code    => 400,
    }) unless $mass;

    my $data;
    try {
        $data = mass_manager()->find({
            $mass_type => $mass,
        });
    } catch {
        API::X->throw({
            message => "Failed to look up mass : $_",
            code    => 500,
        });
    };

    return res 200, $data;
};

get '/api/v1/mass/average/:mass' => sub {
    var mass_type => 'average',

    my $mass = param 'mass';

    forward qq|/api/v1/mass/$mass|;
};

get '/api/v1/mass/monoisotopic/:mass' => sub {
    var mass_type => 'monoisotopic',

    my $mass = param 'mass';

    forward qq|/api/v1/mass/$mass|;
};

true;

__END__

=pod

=cut
