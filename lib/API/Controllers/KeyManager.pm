package API::Controllers::KeyManager;
use Moose;

use Peptide::Model;

has 'model' => (
    is      => 'ro',
    isa     => 'Peptide::Model',
    lazy    => 1,
    builder => '_build_model',
);

sub _build_model {
    return Peptide::Model->new;
}

sub validate_key {
    my ($self, $key) = @_;

    return $self->model->validate_user_key($key);
}

__PACKAGE__->meta->make_immutable;

=pod

API::Controllers::KeyManager

Class for handling key authorization for the API

=head1 validate_key

Look into the database for the requesting key

=cut

1;

