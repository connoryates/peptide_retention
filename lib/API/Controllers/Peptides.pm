package API::Controllers::Peptide;
use Moose;

use Peptide::Model;

has 'model' => (
    is      => 'ro',
    isa     => 'Peptide::Model',
    lazy    => 1,
    builder => '_build_model',
);

sub _build_model {
    return Peptide::Model->new;
}

sub retention_info {
    my ($self, $peptide) = @_;

    return $self->model->get_retention_info({peptide => $peptide});
}

__PACKAGE__->meta->make_immutable;
