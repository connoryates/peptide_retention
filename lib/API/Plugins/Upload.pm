package API::Plugins::Upload;

use Dancer ':syntax';
use Dancer::Plugin;

use API::Controllers::Upload;

register upload_manager => sub {
    return API::Controllers::Upload->new;
};

register_plugin;

true;

=pod

upload_manager

Plugin for using API::Controllers::Upload in Route

=cut

1;
