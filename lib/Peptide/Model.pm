package Peptide::Model;
use Moose;

use Peptide::Schema;

has 'schema' => (
    is      => 'ro',
    isa     => 'Peptide::Schema',
    lazy    => 1,
    builder => '_build_schema',
);

sub _build_schema {
    return Peptide::Schema->new;
}

sub get_retention_info {
    my ($self, $peptide) = @_;

    return $self->schema->peptide->search({peptide => $peptide});
}

sub add_retention_info {
    my ($self, $info) = @_;

    my $bb = $self->assign_bb_vals($info->{peptide});

    die "Cannot determine BullBreese values" unless $bb;

    $info->{bullbreese} = $bb;

    return $self->schema->peptide->insert($info);
}

__PACKAGE__->meta->make_immutable;
