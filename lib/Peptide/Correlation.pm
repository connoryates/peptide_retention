package Peptide::Correlation;
use Moose;

use Peptide::Model;
use Statistics::Basic qw(correlation);

has 'type' => ( is => 'rw', isa => 'Str' );

has 'model' => (
    is      => 'ro',
    isa     => 'Peptide::Model',
    lazy    => 1,
    builder => '_build_model',
);

sub _build_model {
    return Peptide::Model->new;
}

sub correlate_retention_datasets {
    my $self = shift;

    my $type = $self->type or die "Unspecified type";

    my $data;
    if ($type eq 'bullbreese_retention') {
        $data = $self->model->get_bb_retention_correlation_data;
    } elsif ($type eq 'peptide_length_retention') {
        $data = $self->model->get_peptide_retention_correlation_data;
    } else {
        die "Not a valid type. Valid types are:\n\tbullbreese_retention\n\tpeptide_length_retention\n\n";
    }

    die "Extra key, will not correlate correctly" if (keys %$data > 2);

    my $vector_2 = delete $data->{retention}; # Plz change
    my $vector_1 = $data->{ [ keys %$data]->[0] };

    my $corr = $self->correlate($vector_1, $vector_2);

    return defined $corr ? $corr : undef;
}

sub correlate {
    my ($self, $vector_1, $vector_2) = @_;

    return correlation( $vector_1, $vector_2 );
}

__PACKAGE__->meta->make_immutable;

=pod

Peptide::Correlation

my $correlation = Peptide::Correlation->new(
    type => $type
);

$type can be:
    - bullbreese_retention
    - peptide_length_retention

=head1 correlate_retention_datasets

Reads values from based on attribute type from database and uses the corr method from Statistics::Basic
to find correlation.

=cut

1;
