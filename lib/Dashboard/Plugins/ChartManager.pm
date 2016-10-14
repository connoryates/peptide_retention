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
