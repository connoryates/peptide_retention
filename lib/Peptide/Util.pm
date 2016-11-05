package Peptide::Util;
use Moose;

use Hash::Merge;
use Try::Tiny;
use API::X;

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

    if (not defined $hash_1 or not defined $hash_2) {
        API::X->throw({
            message => "Two HashRefs must be provided",
        });
    }

    if (!ref($hash_1) or ref($hash_1) ne 'HASH') {
        API::X->throw({
            message => "Argument 1 must be a HashRef",
        });
    }

    if (!ref($hash_2) or ref($hash_2) ne 'HASH') {
        API::X->throw({
            message => "Argument 2 must be a HashRef",
        });
    }

    my $combined;
    try {
        $combined = $self->merge($hash_1, $hash_2);
    } catch {
        API::X->throw({
            message => "Could not merge hashes : $_",
        });
    };

    return $combined;
}

__PACKAGE__->meta->make_immutable;
