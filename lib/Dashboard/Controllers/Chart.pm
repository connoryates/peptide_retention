package Dashboard::Controllers::Chart;
use Moose;

use Peptide::Model;

has 'model' => (
    is      => 'ro',
    isa     => 'Peptide:Model',
    lazy    => 1,
    builder => '_build_model',
);

sub _build_model {
    return Peptide::Model->new;
}

sub bar_chart_data {
    my ($self, $peptide) = @_;

    return $self->model->get_bar_chart_peptide_data($peptide);
}

__PACKAGE__->meta->make_immutable;
