package API::Cache::Peptide;
use Moose;

extends 'API::Cache';

use Try::Tiny;
use JSON::XS qw(decode_json encode_json);

use constant EXPIRATION_TIME => 8600;

has 'namespace' => ( is => 'rw', isa => 'Str', default => sub { return "peptide" } );

sub set_peptide_cache {
    my ($self, $data) = @_;

    foreach my $required (qw(peptide retention_info)) {
        die "Missing required arg : $required"
          unless defined $data->{$required};
    }

    my $chi = $self->chi;

    # Don't attempt to cache existing keys
    return if $chi->is_valid($data->{peptide});

    my $status;
    try {
        my $peptide = delete $data->{peptide};
        my $json    = encode_json($data);
        $status     = $chi->set($peptide, $json, EXPIRATION_TIME);
    } catch {
        $status = undef;
        warn "Failed to set cache : $_";
    };

    return $status;
}

sub get_peptide_cache {
    my ($self, $peptide) = @_;

    die "Missing required arg : peptide"
      unless defined $peptide;

    my $chi   = $self->chi;
    my $json  = $self->chi->get($peptide);

    return undef unless defined $json;

    my $data;
    try {
        $data = decode_json($json);
    } catch {
        $data = undef;
        warn "Failed to get $peptide from cache : $_";
    };

    return $data;

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
