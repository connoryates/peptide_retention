package API::Plugins::Peptides;

use Dancer ':syntax';
use Dancer::Plugin;

use API::Controllers::Peptides;

register peptide_manager => sub {
    return API::Controllers::Peptides->new;
};

register_plugin;

true;
