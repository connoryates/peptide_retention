package Peptide::Util;
use Moose;

use Scalar::Util qw(looks_like_number);
use Hash::Diff qw(diff left_diff);
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


sub merge_if_different {
    my ($self, $new, $orig) = @_;

    if (not defined $new or not defined $orig) {
        API::X->throw({
            message => "Two HashRefs must be provided",
        });
    }

    if (!ref($new) or ref($new) ne 'HASH') {
        API::X->throw({
            message => "Arg 1 must be a HashRef",
        });
    }

    if (!ref($orig) or ref($orig) ne 'HASH') {
        API::X->throw({
            message => "Arg 2 must be a HashRef",
        });
    }

    my $diff = left_diff($new, $orig);

    if (defined $diff and ref($diff) and ref($diff) eq 'HASH') {
        return $self->hash_merge($new, $orig);
    }

    return $orig;
}

sub ensure_integer {
    my ($self, $data) = @_;

    return unless $data;

    my $ret;
    if (ref($data) and ref($data) eq 'HASH') {
        my %ret = ();

        while (my ($k, $v) = each %$data) {
            $ret{$k} = looks_like_number($v) ? 0 + $v : $v;
        }

        $ret = \%ret;
    }
    elsif (!ref($data)) {
        $ret = looks_like_number($data) ? 0 + $data : $data;
    }

    return $ret;
}

sub to_one {
    my ($self, $num) = @_;

    $num =~ s/\.//g;
    return $self->ensure_integer(int($num));
}

__PACKAGE__->meta->make_immutable;
