package Dashboard::Plugins::ChartManager;

use Dancer ':syntax';
use Dancer::Plugin;

use Dashboard::Controllers::Chart;

register bar_chart_manager => sub {
     return Dashboard::Controllers::Chart->new(
         chart_type => 'bar',
     );
};

register_plugin;

true;

=pod

=head1 bar_chart_manager

Plugin for using Chart controller in Route

=cut

1;
