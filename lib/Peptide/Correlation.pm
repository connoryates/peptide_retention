package Peptide::Correlation;
use Moose;

use API::X;
use Try::Tiny;
use Peptide::Model;
use Log::Any qw/$log/;
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
    my ($self, $filter) = @_;

    my $type = $self->type or API::X->throw({
        message => "Unspecified type"
    });

    my ($data, @vector_1, @vector_2);

    # Only 1 prediction algorithm currently supported!
    if ($type eq 'bullbreese_retention') {
        if (defined $filter) {
            if (ref($filter) and ref($filter) eq 'HASH') {

                foreach my $required (qw(filter data)) {
                    if (not defined $filter->{$required}) {
                        API::X->throw({
                            message => "Missing required param : $required",
                        });
                    }
                }

                try {
                    $data = $self->model->get_peptide_retention_filtered_data($filter);
                } catch {
                    API::X->throw({
                        message => "Failed to get filtered correlation data : $_",
                    });
                };
            }
            else {
                API::X->throw({
                    message => "Arg filter must be a HashRef",
                });
            }
        }
        else {
            $data = $self->model->get_bb_retention_correlation_data;
        } 
        @vector_1 = map { $_->{predictions}->[0]->{predicted_time} } @$data;
        @vector_2 = map { $_->{bullbreese} } @$data;
    }
    elsif ($type eq 'peptide_length_retention') {
        $data = $self->model->get_peptide_retention_correlation_data;

        @vector_1 = map { $_->{predictions}->[0]->{predicted_time} } @$data;
        @vector_2 = map { $_->{length} } @$data;
    } else {
        API::X->throw({
            message => "Not a valid type. Valid types are: bullbreese_retention, peptide_length_retention"
        });
    }

    my $corr;
    try {
        $corr = $self->correlate(\@vector_1, \@vector_2);
    } catch {
        $log->warn("Failed to correlate datasets: $_");

        API::X->throw({
            message => "Failed to correlate datasets : $_"
        });
    };

    return defined $corr ? $corr : undef;
}

sub correlate {
    my ($self, $vector_1, $vector_2) = @_;

    if (not defined $vector_1 or not defined $vector_2) {
        API::X->throw({
            message => "Two ArrayRefs must be supplied",
        });
    }

    if (!ref($vector_1) or ref($vector_1) ne 'ARRAY') {
        API::X->throw({
            message => "Argument 1 must be an ArrayRef",
        });
    }

    if (!ref($vector_2) or ref($vector_2) ne 'ARRAY') {
        API::X->throw({
            message => "Argument 2 must be an ArrayRef",
        });
    }

    my $correlation;
    try {
       $correlation = correlation( $vector_1, $vector_2 );
    } catch {
        API::X->throw({
            message => "Failed to correlate datasets : $_",
        });
    };

    return $correlation;
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
