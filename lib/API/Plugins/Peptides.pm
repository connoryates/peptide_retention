package API::Plugins::Peptides;

use Dancer ':syntax';
use Dancer::Plugin;

use API::Controllers::Peptides;

register peptide_manager => sub {
    return API::Controllers::Peptides->new;
};

register_plugin;

true;

=pod

=head1 peptide_manger

Plugin to handle API::Controllers::Peptides in Route

=cut

1;
