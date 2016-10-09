package Peptide::Client;
use Moose;

use Furl;

has 'furl' => (
    is      => 'ro',
    isa     => 'Furl',
    lazy    => 1,
    builder => '_build_furl',
);

sub _build_furl {
    return Furl->new;
}

sub insert_peptide_info {
    my ($self, $info) = @_;
}

sub get_peptide_info {

}

__PACKAGE__->meta->make_immutable;
