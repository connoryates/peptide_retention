package API::Cache::Mass;
use Moose;

extends 'API::Cache';

use API::X;
use Try::Tiny;
use Log::Any qw/$log/;
use JSON::XS qw(decode_json encode_json);

use constant EXPIRATION_TIME => 8600;

has 'namespace' => ( is => 'rw', isa => 'Str', default => sub { return "peptide" } );

sub set_mass_cache {
    my ($self, $data) = @_;

    API::X->throw({
        message => "Missing required param : $data",
    }) unless $data;

    foreach my $required (qw(mass peptide)) {
        API::X->throw({
            message => "Missing required arg : $required",
        }) unless $data->{$required};
    }

    my $chi = $self->chi;

    $data->{mass} =~ s/\.//;

    # Don't attempt to cache existing keys
    return 1 if $chi->is_valid($data->{mass});

    my $status;
    try {
        my $json = encode_json($data);
        $status  = $chi->set($data->{mass}, $json, EXPIRATION_TIME);
    } catch {
        $status = undef;
        $log->warn("Failed to set cache : $_");
    };

    return !!$status;
}

sub get_mass_cache {
    my ($self, $mass) = @_;

    API::X->throw({
        message => "Missing required arg : mass",
    }) unless $mass;

    $mass =~ s/\.//;

    my $data;
    try {
        my $json = $self->chi->get($mass);
           $data = decode_json($json);
    } catch {
        $data = undef;
        $log->warn("Failed to get $mass from cache : $_");
    };

    return $data;
}

sub is_cached {
    my ($self, $mass) = @_;

    API::X->throw({
        message => "Missing required param : mass",
    }) unless $mass;

    return $self->chi->is_valid($mass);
}

__PACKAGE__->meta->make_immutable;

=pod

API::Cache::Mass

Class for handling Mass Redis cache

=head1 set_mass_cache

Sets a cache entry with the mass as the key and the retention information as the value.
Encodes information to JSON before set.

=head1 get_mass_cache

Gets a cache entry based on the supplied peptide sequence. Decodes the JSON structure before returning.

=cut
