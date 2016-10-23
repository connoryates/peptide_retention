package API::Plugins::KeyManager;

use Dancer ':syntax';
use Dancer::Plugin;

use API::Controllers::KeyManager;

register key_manager => sub {
    return API::Controllers::KeyManager->new
};

register_plugin;

true;

=pod

=head1 key_manager

Plugin for handling any API key authorization. Future feature

=cut
