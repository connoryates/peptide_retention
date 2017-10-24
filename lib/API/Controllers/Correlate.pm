package API::Controllers::Correlate;
use Moose;

use Peptide::Model;
use API::Cache;
use Try::Tiny;
use API::X;

has 'model' => (
    is      => 'ro',
    isa     => 'Peptide::Model',
    lazy    => 1,
    builder => '_build_model',
);

has 'cache' => (
    is      => 'ro',
    isa     => 'API::Cache',
    lazy    => 1,
    builder => '_build_cache',
);

sub _build_model {
    return Peptide::Model->new;
}

sub _build_cache {
    return API::Cache->new;
}

sub correlate_peptides {
    my ($self, $data) = @_;

    my $alg = $data->{algorithm};

    if (not $alg) {
        API::X->throw({
            message => "Missing required arg : algorithm",
        });
    }

    if ($alg ne 'hodges') {
        API::X->throw({
            message => "Unsupported algorithm: $alg",
        });
    }

    my $length = $data->{length} || undef;

    my $corr;
    try {
        $corr = $self->model->correlate_data({
            filter => {
                length    => $length,
                algorithm => 'hodges',
            }
        });
    } catch {
        API::X->throw({
            message => "Failed to get correlation data: $_",
        });
    };

    return $corr;
}

__PACKAGE__->meta->make_immutable;

=pod

API::Controllers::Correlate

Controller class for correlating peptide retention data through the Correlate Route

=cut
