package API::Cache::Correlate;
use Moose;

extends 'API::Cache';

use API::X;
use Try::Tiny;
use Log::Any qw/$log/;
use JSON::XS qw(decode_json encode_json);

use constant EXPIRATION_TIME => 8600;

has 'namespace' => ( is => 'rw', isa => 'Str', default => sub { return "correlate" } );

sub set_correlate_cache {
    my ($self, $data) = @_;

    if (not defined $data) {
        API::X->throw({
            message => "Missing required param : data",
        });
    }

    if ( !ref($data) or ref($data) ne 'HASH' ) {
        API::X->throw({
            message => "Param data must be a HashRef",
        });
    }

    foreach my $required (qw(key correlation)) {
        API::X->throw({
            message => "Missing required arg : $required",
        }) unless defined $data->{$required};
    }

    my $chi = $self->chi;

    # Don't attempt to cache existing keys
    return if $chi->is_valid($data->{key});

    my $status;
    try {
        my $key  = delete $data->{key};
        my $json = encode_json({ correlation => "$data->{correlation}" });
        $status  = $chi->set($key, $json, EXPIRATION_TIME);
    } catch {
        $status  = undef;
        $log->warn("Failed to set cache : $_");
    };

    return $status;
}

sub get_correlate_cache {
    my ($self, $key) = @_;

    if (not defined $key) {
        API::X->throw({
            message => "Missing required param : key",
        });
    }

    my $chi = $self->chi;
 
    my $json;
    try {
        $json = $self->chi->get($key);
    } catch {
        $log->warn("Failed to get cache data for $key : $_");
    };

    return undef unless defined $json;

    my $data;
    try {
        $data = decode_json($json);
    } catch {
        $data = undef;
        $log->warn("Failed to get $key from cache : $_");
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

API::Cache::Correlate

Class for caching correlation data. Uses the filter name as the cache key

=head1 set_correlate_cache

Sets and serializers the correlation data. Uses the filter name as the key

=head2 get_correlate_cache

Gets and deserializes the correlation data

=cut

1;
