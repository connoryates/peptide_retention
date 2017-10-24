package API::Routes::Correlate;

use Dancer ':syntax';
use Dancer::Exception qw(:all);
use Dancer::Plugin::Res;
use API::Plugins::CorrelateManager;
use API::X;

set serializer => 'JSON';

hook 'before' => sub {
    my $params = params || {};

    var authorized => 1;
};

get '/api/v1/correlate/bullbreese/length/:length' => sub {
    var length => param 'length';

    forward '/api/v1/correlate/bullbreese';
};

get '/api/v1/correlate/bullbreese' => sub {
    my $length   = var 'length' || undef;
    my $auth     = var 'authorized';

    API::X->throw({
         message => "Unauthorized",
         code    => 401
    }) unless $auth;

    my $correlation;
    try {
        $correlation = correlate_manager()->correlate_peptides({
            length    => $length,
            algorithm => 'hodges',
        });
    } catch {
        API::X->throw({
            message => "Failed to get correlation data : $_",
            code    => 500
        });
    };

    # I think I'm getting a context high - Stewie Griffin
    return res 200, +{ correlation => "$correlation" };
};

true;

=pod

post /api/v1/correlate/bull_breese/peptide_length

REST route to handle correlation data. Accepts a parameter "peptide_length" that can either
be a the length of a peptide or "all" which will correlate peptide of all lengths

For some reason, JSON serialization fails unless $correlation is forced into string context...

=cut

1;
