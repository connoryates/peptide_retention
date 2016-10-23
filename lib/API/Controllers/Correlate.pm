package API::Controllers::Correlate;
use Moose;

use Peptide::Model;
use Peptide::Correlation;
use API::Cache;
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

has 'cache' => (
    is      => 'ro',
    isa     => 'API::Cache',
    lazy    => 1,
    builder => '_build_cache',
);

sub _build_model {
    return Peptide::Model->new;
}

sub _build_correlation {
    # TODO: deprecate this type
    return Peptide::Correlation->new(
        type => 'bullbreese_retention',
    );
}

sub _build_cache {
    return API::Cache->new;
}

sub correlate_peptides {
    my ($self, $data) = @_;

    foreach my $required (qw(filter data)) {
        die "Missing required arg : $required"
          unless defined $data->{$required};
    }

    my $cache = $self->cache;

    if ( my $cached = $cache->get_correlate_cache($data->{filter}) ) {
        return $cached;
    }

    my $filtered;
    try {
        $filtered  = $self->model->get_peptide_retention_filtered_data($data);
    } catch {
        die "Failed to get correlation data : $_";
    };

    my $vector_1   = $filtered->{bullbreese};
    my $vector_2   = $filtered->{retention_info};

    my $correlation;
    try {
        $correlation = $self->correlation->correlate($vector_1, $vector_2);
    } catch {
        die "Failed to correlate datasets : $_";
    };

    $cache->set_correlate_cache({
        filter      => $data->{filter},
        correlation => $correlation,
    });

    return $correlation;

}

__PACKAGE__->meta->make_immutable;

=pod

API::Controllers::Correlate

Controller class for correlating peptide retention data through the Correlate Route

=cut
