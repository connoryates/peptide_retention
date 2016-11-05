package API::X;
use Moose;

extends 'Throwable::Error';

__PACKAGE__->meta->make_immutable;
