package API::Cache::Peptide;
use Moose;

extends 'API::Cache';

use API::X;
use Try::Tiny;
use Log::Any qw/$log/;
use JSON::XS qw(decode_json encode_json);

use constant EXPIRATION_TIME => 8600;

has 'namespace' => ( is => 'rw', isa => 'Str', default => sub { return "peptide" } );

sub set_peptide_cache {
    my ($self, $data) = @_;

    if (not defined $data) {
        API::X->throw({
            message => "Missing required param : $data",
        });
    }

    foreach my $required (qw(peptide retention_info)) {
        API::X->throw({
            message => "Missing required arg : $required",
        }) unless defined $data->{$required};
    }

    my $chi = $self->chi;

    # Don't attempt to cache existing keys
    return 1 if $chi->is_valid($data->{peptide});

    my $status;
    try {
        my $peptide = delete $data->{peptide};
        my $json    = encode_json($data->{retention_info});
        $status     = $chi->set($peptide, $json, EXPIRATION_TIME);
    } catch {
        $status = undef;
        $log->warn("Failed to set cache : $_");
    };

    return $status;
}

sub get_peptide_cache {
    my ($self, $peptide) = @_;

    if (not defined $peptide) {
        API::X->throw({
            message => "Missing required arg : peptide",
        });
    }

    my $chi   = $self->chi;
    my $json  = $self->chi->get($peptide);

    return undef unless defined $json;

    my $data;
    try {
        $data = decode_json($json);
    } catch {
        $data = undef;
        $log->warn("Failed to get $peptide from cache : $_");
    };

    return $data;
}

sub is_cached {
    my ($self, $peptide) = @_;

    if (not defined $peptide) {
        API::X->throw({
            message => "Missing required param : peptide",
        });
    }

    return $self->chi->is_valid($peptide);
}

sub remove_key {
    my ($self, $key) = @_;

    if (not defined $key) {
        API::X->throw({
            message => "Missing required param : key",
        });
    }

    my $status;
    try {
        $status = $self->chi->remove($key);
    } catch {
        $status = undef;
        $log->warn("Failed to remove cache key : $_");
    };

    return $status;
}

__PACKAGE__->meta->make_immutable;

=pod

API::Cache::Peptide

Class for handling Peptide Redis cache

=head1 set_peptide_cache

Sets a cache entry with the peptide sequence as the key and the retention information as the value.
Encodes information to JSON before set.

=head2 get_peptide_cache

Gets a cache entry based on the supplied peptide sequence. Decodes the JSON structure before returning.

=cut
