package API::Plugins::Peptide;

use Dancer ':syntax';
use Dancer::Plugin;

use API::Controllers::Peptide;

plugin peptide_manager => sub {
    return API::Controllers::Peptide->new;
};

register_plugin;
