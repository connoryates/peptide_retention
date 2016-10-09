package Peptide::Client;
use Moose;

use Furl;

my $URL = "http://192.168.0.8:5000/api/v1/";

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

    return $self->furl->post($URL, []. $info);
}

sub get_peptide_info {
    my ($self, $info) = @_;

    return $self->furl->post($URL, []. $info);
}

__PACKAGE__->meta->make_immutable;
