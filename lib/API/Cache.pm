package API::Cache;
use Moose;

use CHI;
use Peptide::Config;
use API::Cache::Peptide;

our $CHI;

has 'namespace' => ( is => 'rw', isa => 'Str' );

has 'chi' => (
    is      => 'ro',
    isa     => 'CHI::Driver::Redis',
    lazy    => 1,
    builder => '_build_chi',
);

has 'config' => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_config',
);

has 'peptide' => (
    is      => 'ro',
    isa     => 'API::Cache::Peptide',
    lazy    => 1,
    builder => '_build_peptide',
    handles => [qw(get_cached_peptide set_peptide_cache)],
);

# NOT FOR PUBLIC USE - namespace is set by subclasses!
sub _build_chi {
    my $self   = shift;
    my $config = $self->config->{chi_config};

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

__PACKAGE__->meta->make_immutable;
