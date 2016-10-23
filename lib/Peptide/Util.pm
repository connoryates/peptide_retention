package Peptide::Util;
use Moose;

use Hash::Merge;

has 'merger' => (
    is       => 'ro',
    isa      => 'Hash::Merge',
    lazy     => 1,
    builder  => '_build_merger',
    handles  => [qw(merge)],
);

sub _build_merger {
    return Hash::Merge->new('LEFT_PRECEDENT');
}

sub hash_merge {
    my ($self, $hash_1, $hash_2) = @_;

    my $combined = $self->merge($hash_1, $hash_2);

    return $combined;
}

__PACKAGE__->meta->make_immutable;
