package API::Routes::Correlate;

use Dancer ':syntax';
use Dancer::Exception qw(:all);
use Dancer::Plugin::Res;
use API::Plugins::CorrelateManager;

set serializer => 'JSON';

hook 'before' => sub {
    my $params = params || {};

    var authorized => 1;
};

post '/api/v1/correlate/bull_breese/peptide_length' => sub {
    my $params = params || {};

    my $auth   = var 'authorized';

    send_error("Unauthorized" => 401) unless defined $auth;
    send_error("Missing required arg : peptide_length" => 400)
      unless defined $params->{peptide_length};

    my $correlation;
    try {
        $correlation = correlate_manager()->correlate_peptides({
            data   => $params->{peptide_length},
            filter => 'peptide_length',
        });
    } catch {
        die "Failed to get correlation data : $_";
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
