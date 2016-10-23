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

=pod

Dashboard::Controller::Chart

Class for handling calls to Model from Route

=head1 bar_chart_data

Return bar chart data for a given peptide input

=cut
