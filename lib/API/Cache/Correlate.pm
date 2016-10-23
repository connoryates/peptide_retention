package API::Cache::Correlate;
use Moose;

extends 'API::Cache';

use Try::Tiny;
use JSON::XS qw(decode_json encode_json);

use constant EXPIRATION_TIME => 8600;

has 'namespace' => ( is => 'rw', isa => 'Str', default => sub { return "correlate" } );

sub set_correlate_cache {
    my ($self, $data) = @_;

    foreach my $required (qw(filter correlation)) {
        die "Missing required arg : $required"
          unless defined $data->{$required};
    }

    my $chi = $self->chi;

    # Don't attempt to cache existing keys
    return if $chi->is_valid($data->{filter});

    my $status;
    try {
        my $filter = delete $data->{filter};
        my $json   = encode_json({ correlation => $data->{correlation} });
        $status    = $chi->set($filter, $json, EXPIRATION_TIME);
    } catch {
        $status = undef;
        warn "Failed to set cache : $_";
    };

    return $status;
}

sub get_correlate_cache {
    my ($self, $filter) = @_;

    die "Missing required arg : filter"
      unless defined $filter;

    my $chi   = $self->chi;
    my $json  = $self->chi->get($filter);

    return undef unless defined $json;

    my $data;
    try {
        $data = decode_json($json);
    } catch {
        $data = undef;
        warn "Failed to get $filter from cache : $_";
    };

    return $data;
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
