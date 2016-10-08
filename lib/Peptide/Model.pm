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

__PACKAGE__->meta->make_immutable;
