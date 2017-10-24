package API::Plugins::MassManager;

use Dancer ':syntax';
use Dancer::Plugin;
use API::Controllers::Mass;

register mass_manager => sub {
    return API::Controllers::Mass->new;
};

register_plugin;

true;

