package API::Controllers::Peptides;
use Moose;

use Peptide::Util;
use Peptide::Model;
use API::Cache;
use Try::Tiny;
use API::X;

has model => (
    is      => 'ro',
    isa     => 'Peptide::Model',
    lazy    => 1,
    builder => '_build_model',
);

has cache => (
    is      => 'ro',
    isa     => 'API::Cache',
    lazy    => 1,
    builder => '_build_cache',
);

has util => (
    is      => 'ro',
    isa     => 'Peptide::Util',
    lazy    => 1,
    builder => '_build_util',
);

sub _build_model {
    return Peptide::Model->new;
}

sub _build_cache {
    return API::Cache->new;
}

sub _build_util {
    return Peptide::Util->new;
}

sub retention_info {
    my ($self, $peptide) = @_;

    API::X->throw({
        message => "Missing required param : `peptide`",
    }) unless $peptide;

    API::X->throw({
        message => "Argument `peptide` must be a string",
    }) if ref($peptide);

    my $cache = $self->cache;

    if (my $cached = $cache->get_peptide_cache($peptide)) {
        return $cached;
    }

    my $ret_info;
    try {
        $ret_info = $self->model->get_retention_info($peptide);

        if (defined $ret_info) {
            $cache->set_peptide_cache({
                peptide        => $peptide,
                retention_info => $ret_info,
            });
        }
    } catch {
        API::X->throw({
            message => "Failed to get retention info for $peptide : $_",
        });
    };

    return $ret_info;
}

sub add_retention_info {
    my ($self, $info) = @_;

    API::X->throw({
        message => "Missing required param : `info`",
    }) unless $info;

    if (!ref($info) or ref($info) ne 'HASH') {
        API::X->throw({
            message => "Argument `info` must be a HashRef",
        });
    }

    my $peptide = $info->{peptide};
    my $cache   = $self->cache;

    if ($cache->is_cached($peptide)) {
        $cache->remove_key($peptide);
    }

    return $self->model->add_retention_info($info);
}

sub get_all {
    my ($self, $args) = @_;

    API::X->throw({
        message => 'Missing required args : args',
    }) unless $args;

    my $filter  = $args->{filter};
    my %payload = ();

    $payload{length} = $filter->{length} if $filter->{length};

    my $peptides;
    try {
        $peptides = $self->model->get_all_peptides(\%payload);
    } catch {
        API::X->throw({
            message => "Failed to get all peptides : $_",
        });
    };

    return $peptides;
}

sub search {
    my ($self, $args) = @_;

    API::X->throw({
        message => 'Missing required args : args',
    }) unless $args;

    my %payload = (
        length   => $args->{length}   || undef,
        keywords => $args->{keywords} || undef,
        limit    => $args->{limit}    || undef,
        offset   => $args->{offset}   // 0,
    );

    my ($results, $next);
    try {
        $results = $self->model->search_peptides(\%payload);
        $next    = $self->cache->set_next_search(\%payload);
    } catch {
        API::X->throw({
            message => "Failed to search peptides : $_",
        });
    };

    return {
        results => $results, 
        next    => $next,
        limit   => $args->{limit},
        offset  => $args->{offset},
    };
}

sub next {
    my ($self, $id) = @_;

    API::X->throw({
        message => 'Missing required arg : id',
    }) unless $id;

    my $ret;
    try {
        my $cache = $self->cache;

        my $cached = $cache->get_next_search($id);
        my $limit  = $cached->{limit};

        $cached->{offset} += $limit;

        my $results = $self->model->search_peptides($cached);
        my $next    = $cache->set_next_search($cached);

        my %results = (
            results => $results,
            next    => $next,
            limit   => $limit,
            offset  => $cached->{offset},
        );

        $ret = \%results;
    } catch {
        API::X->throw({
            message => "Failed to get next query result : $_",
        });
    };

    return $ret;
}

sub counts {
    my $self = shift;

    my %counts = ();
    try {
        my $model = $self->model;

        $counts{total_peptides} = $model->get_peptide_count;
        $counts{total_proteins} = $model->get_protein_count;
    } catch {
        API::X->throw({
            message => "Failed to get counts : $_",
        });
    };

    return \%counts;
}

__PACKAGE__->meta->make_immutable;

=pod

API::Controlers::Peptide

Class for controlling caching and calls to Model for API::Routes::Peptides

=head1 retention_info

Checks the cache for retention info first and returns it if it's found.

If not, calls get_retention_info from Model

=head2 add_retention_info

Checks the cache to see if the peptide in question has been cached.
It then merges the hash structure with a left precedet (the new data)
and recaches. It then calls the model to add the retention info


Calls Model to add retention info

=cut

1;
