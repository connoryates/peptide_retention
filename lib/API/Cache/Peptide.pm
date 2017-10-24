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

    API::X->throw({
        message => "Missing required param : $data",
    }) unless $data;

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

    API::X->throw({
        message => "Missing required arg : peptide",
    }) unless $peptide;

    my $data;
    try {
        my $json = $self->chi->get($peptide);
           $data = decode_json($json);
    } catch {
        $data = undef;
        $log->warn("Failed to get $peptide from cache : $_");
    };

    return $data;
}

sub is_cached {
    my ($self, $peptide) = @_;

    API::X->throw({
        message => "Missing required param : peptide",
    }) unless $peptide;

    return $self->chi->is_valid($peptide);
}

sub get_next_search {
    my ($self, $key) = @_;

    API::X->throw({
        message => "Missing required param : key",
    }) unless $key;

    my $args;
    try {
        my $json = $self->chi->get($key);
           $args = decode_json($json);
    } catch {
        $log->warn("Failed to get next search result : $_");

        API::X->throw({
            message => "Failed to get next search result : $_",
        });
    };

    return $args;
}

sub set_next_search {
    my ($self, $args) = @_;

    API::X->throw({
        message => "Missing required param : args",
    }) unless $args;

    API::X->throw({
        message => "Param args must be a reference",
    }) unless ref($args);

    API::X->throw({
        message => "Param args must be a HASH",
    }) unless ref($args) eq 'HASH';

    my $key;
    try {
        my $json = encode_json($args);
           $key  = $self->_create_uuid;

        $self->chi->set($key, $json, EXPIRATION_TIME);
    } catch {
        $log->warn("Failed to set next search : $_");
        $key = undef;
    };

    return $key;
}

sub remove_key {
    my ($self, $key) = @_;

    API::X->throw({
        message => "Missing required param : key",
    }) unless $key;

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

=head1 get_peptide_cache

Gets a cache entry based on the supplied peptide sequence. Decodes the JSON structure before returning.

=cut
