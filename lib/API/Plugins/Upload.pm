package API::Plugins::Upload;

use Dancer ':syntax';
use Dancer::Plugin;

use API::Controllers::Upload;

register upload_manager => sub {
    return API::Controllers::Upload->new;
};

register_plugin;
