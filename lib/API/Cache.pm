package API::Cache;
use Moose;

use CHI;
use API::X;
use Try::Tiny;
use Data::UUID;
use Peptide::Config;
use API::Cache::Mass;
use API::Cache::Peptide;
use API::Cache::Correlate;

our $CHI;

has namespace => ( is => 'rw', isa => 'Str' );

has chi => (
    is      => 'ro',
    isa     => 'CHI::Driver::Redis',
    lazy    => 1,
    builder => '_build_chi',
);

has config => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_config',
);

has peptide => (
    is      => 'ro',
    isa     => 'API::Cache::Peptide',
    lazy    => 1,
    builder => '_build_peptide',
    handles => [qw(
        get_peptide_cache set_peptide_cache
        get_next_search set_next_search
    )],
);

has correlate => (
    is      => 'ro',
    isa     => 'API::Cache::Correlate',
    lazy    => 1,
    builder => '_build_correlate',
    handles => [qw(get_correlate_cache set_correlate_cache)],
);

has mass => (
    is      => 'ro',
    isa     => 'API::Cache::Mass',
    lazy    => 1,
    builder => '_build_mass',
    handles => [qw(get_mass_cache set_mass_cache)],
);

# NOT FOR PUBLIC USE - namespace is set by subclasses!
sub _build_chi {
    my $self   = shift;

    my $config;
    try {
        $config = $self->config->{chi_config};
    } catch {
        API::X->throw({
            message => "Cannot find CHI config! : $_",
        });
    };

    $config->{namespace} = $self->namespace;

    $CHI ||= CHI->new(%$config);

    return $CHI;
}

sub _build_config {
    return Peptide::Config->new->config;
}

sub _build_peptide {
    return API::Cache::Peptide->new;
}

sub _build_correlate {
    return API::Cache::Correlate->new;
}

sub _build_mass {
    return API::Cache::Mass->new;
}

sub _create_uuid {
    my $self = shift;

    my $generator = Data::UUID->new;
    my $uuid      = $generator->create;

    return lc($generator->to_string($uuid));
}

__PACKAGE__->meta->make_immutable;

=pod

API::Cache

Class for handling caching in the API

Providers attributes and handles for subclasses

=cut
