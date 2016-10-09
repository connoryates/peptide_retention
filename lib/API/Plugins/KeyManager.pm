package API::Plugins::KeyManager;

use Dancer ':syntax';
use Dancer::Plugin;

use API::Controllers::KeyManager;

register key_manager => sub {
    return API::Controllers::KeyManager->new
};

register_plugin;
