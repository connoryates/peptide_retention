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

#sub get_retention_info {
#    my ($self, $peptide) = @_;

#    return $self->schema->peptide->search({peptide => $peptide})
#      || $self->_get_retention_info($peptide);
#}

sub _get_retention_info {
    my ($self, $peptide) = @_;

    return $self->retention->tryptic_vals($peptide);
}

sub add_retention_info {
    my ($self, $info) = @_;

    my $bb = $self->assign_bb_vals($info->{peptide});

    die "Cannot determine BullBreese values" unless $bb;

    $info->{bullbreese} = $bb;

    return $self->schema->peptide->insert($info);
}

sub validate_api_key {
    return 1;
}
__PACKAGE__->meta->make_immutable;
