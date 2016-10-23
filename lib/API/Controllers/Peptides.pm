package API::Controllers::Peptides;
use Moose;

use Peptide::Util;
use Peptide::Model;
use API::Cache;
use Try::Tiny;

has 'model' => (
    is      => 'ro',
    isa     => 'Peptide::Model',
    lazy    => 1,
    builder => '_build_model',
);

has 'cache' => (
    is      => 'ro',
    isa     => 'API::Cache',
    lazy    => 1,
    builder => '_build_cache',
);

has 'util' => (
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
        die "Failed to get retention info for $peptide : $_";
    };

    return $ret_info;
}

sub add_retention_info {
    my ($self, $info) = @_;


#    my $peptide = $info->{peptide};
#    my $cache   = $self->cache;

#    if ($cache->is_cached($peptide)) {
#        my $cached    = $cache->get_peptide_cache($peptide);

        # Order matters! Left-precedent
#        my $new_cache = $self->util->hash_merge(
#            {
#                prediciton_algorithm => $info->{prediciton_algorithm},
#                retention_info       => $info->{retention_info},
#                peptide              => $peptide,
#            },
#            $cached,
#        );
#
#        $cache->set_peptide_cache($new_cache);
#    }

    return $self->model->add_retention_info($info);

}

__PACKAGE__->meta->make_immutable;

=pod

API::Controlers::Peptide

Class for controlling caching and calls to Model for API::Routes::Peptides

=head1 retention_info

Checks the cache for retention info first and returns it if it's found.

If not, calls get_retention_info from Model

=head2 add_retention_info

Calls Model to add retention info

=cut

1;
