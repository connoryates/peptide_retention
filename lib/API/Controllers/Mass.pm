package API::Controllers::Mass;
use Moose;

use API::X;
use Try::Tiny;
use API::Cache;
use Peptide::Model;

has model => (
    is      => 'ro',
    isa     => 'Peptide::Model',
    lazy    => 1,
    builder => '_build_model',
);

has cache => (
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

sub find {
    my ($self, $args) = @_;

    API::X->throw({
        message => 'Missing required arg : args',
    }) unless $args;

    if (not $args->{average} xor $args->{monoisotopic}) {
        API::X->throw({
            message => 'Missing required arg : mass_type',
        });
    }

    my $data;
    try {
        $data = $self->model->search_mass($args);
    } catch {
        API::X->throw({
            message => "Failed to search mass : $_",
        });
    };

    return $data;
}

__PACKAGE__->meta->make_immutable;

__END__

=pod

=cut
