package API::Controllers::Peptides;
use Moose;

use Peptide::Model;
use Peptide::Client;

has 'model' => (
    is      => 'ro',
    isa     => 'Peptide::Model',
    lazy    => 1,
    builder => '_build_model',
);

has 'client' => (
    is      => 'ro',
    isa     => 'Peptide::Client',
    lazy    => 1,
    builder => '_build_client',
);

sub _build_model {
    return Peptide::Model->new;
}

sub _build_client {
    return Peptide::Client->new;
}

sub retention_info {
    my ($self, $peptide) = @_;

    return $self->model->get_retention_info($peptide);
}

sub add_retention_info {
    my ($self, $info) = @_;

    return $self->model->add_retention_info($info);

}

__PACKAGE__->meta->make_immutable;
