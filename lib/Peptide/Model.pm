package Peptide::Model;
use Moose;

use Peptide::Schema;
use Peptide::Retention;

has 'schema' => (
    is      => 'ro',
    isa     => 'Peptide::Schema',
    lazy    => 1,
    builder => '_build_schema',
);

has 'retention' => (
    is      => 'ro',
    isa     => 'Peptide::Retention',
    lazy    => 1,
    builder => '_build_retention',
);

sub _build_schema {
    return Peptide::Schema->new;
}

sub _build_retention {
    return Peptide::Retention->new;
}

sub get_retention_info {
    my ($self, $peptide) = @_;

    return $self->schema->peptide->search({peptide => $peptide})
      || $self->_get_retention_info($peptide);
}

sub _get_retention_info {
    my ($self, $peptide) = @_;

    my $info = $self->retention->tryptic_vals($peptide);

    $self->add_retention_info($info);

    return $info;
}

sub add_retention_info {
    my ($self, $info) = @_;

    die "No retention info key detected" unless defined $info->{retention_info};

    return $self->schema->uniprot_yeast->insert($info->{retention_info});
}

sub validate_api_key {
    return 1;
}

__PACKAGE__->meta->make_immutable;
