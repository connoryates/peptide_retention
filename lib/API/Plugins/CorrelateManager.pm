package API::Plugins::CorrelateManager;

use Dancer ':syntax';
use Dancer::Plugin;

use API::Controllers::Correlate;

register 'correlate_manager' => sub {
    return API::Controllers::Correlate->new;
};

register_plugin;

true;

=pod

=head1 correlate_manager

Plugin for handling Controller use in the Correlate route

=cut
