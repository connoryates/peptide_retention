package API::Controllers::Correlate;
use Moose;

use Peptide::Model;
use Peptide::Correlation;
use Try::Tiny;

has 'model' => (
    is      => 'ro',
    isa     => 'Peptide::Model',
    lazy    => 1,
    builder => '_build_model',
);

has 'correlation' => (
    is      => 'ro',
    isa     => 'Peptide::Correlation',
    lazy    => 1,
    builder => '_build_correlation',
);

sub _build_model {
    return Peptide::Model->new;
}

sub _build_correlation {
    # TODO: deprecate this
    return Peptide::Correlation->new(
        type => 'bullbreese_retention',
    );
}

sub correlate_peptides {
    my ($self, $data) = @_;

    die "Missing required arg : peptide_length"
      unless defined $data->{peptide_length};

    my $filtered;
    try {
        $filtered  = $self->model->get_peptide_retention_filtered_data($data);
    } catch {
        die "Failed to get correlation data : $_";
    };

    use Data::Dumper;
    print Dumper $filtered;
 
    my $vector_1   = $filtered->{bullbreese};
    my $vector_2   = $filtered->{retention_info};

    my $correlation;
    try {
        $correlation = $self->correlation->correlate($vector_1, $vector_2);
    } catch {
        die "Failed to correlate datasets : $_";
    };

    return $correlation;

}

__PACKAGE__->meta->make_immutable;

=pod

API::Controllers::Correlate

Controller class for correlating peptide retention data through the Correlate Route

=cut
