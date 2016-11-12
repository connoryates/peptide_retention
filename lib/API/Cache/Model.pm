package API::Cache::Model;
use Moose;

extends 'API::Cache';

use API::X;
use Try::Tiny;
use Log::Any qw/$log/;
use JSON::XS qw(decode_json encode_json);

use constant EXPIRATION_TIME => 8600;

has 'namespace' => ( is => 'ro', isa => 'Str', default => sub { 'model_cache' } );

sub set_model_cache {
    my ($self, $data) = @_;

    if (not defined $data) {
        API::X->throw({
            message => "Missing required arg : data",
        });
    }

    my $chi = $self->chi;
    my $timestamp = time();

    my $status;
    try {
        my $json   = encode_json($data);
           $status = $chi->set($timestamp, $json, EXPIRATION_TIME);
    } catch {
        $status = undef;
        $log->warn("Failed to set cache : $_");
    };

    return $status;
}

sub get_model_cache {
    my ($self, $data) = @_;

    if (not defined $data) {
        API::X->throw({
            message => "Missing required arg : data",
        });
    }

    my $chi = $self->chi;

    my @data;
    try {
        my @keys = $chi->get_keys();

        foreach my $key (@keys) {
            my $json = $chi->get($key);
            my $data = decode_json($json);

            if (defined $data) {
                push @data, $data;
                $chi->remove($key);
            }
        }
    } catch {
        API::X->throw({
            message => "Failed to get data from cache : $_",
        });
    }; 

    return \@data;
}

__PACKAGE__->meta->make_immutable;
