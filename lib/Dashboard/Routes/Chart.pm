package Dashboard::Routes::Chart;

use Dancer ':syntax';
use Dancer::Exception qw(:all);
use Dashboard::Plugins::ChartManager;

get '/dashboard/chart/bar/:peptide' => sub {
    my $peptide = param 'peptide';

    send_error("Missing required param peptide" => 400) unless defined $peptide;

    my $data;
    try {
        $data = bar_chart_manager()->bar_chart_data($peptide);
    } catch {
        send_error("Failed to graph bar data for peptide : $peptide : reason : $_", => 500);
    };

    foreach my $required ( qw(algorithm bullbreese retention) ) {
        send_error("Missing required param : $required") unless defined $required;
    }

    return;
#     template 'bar_chart';
#    template 'bar_chart', +{
#        algorithm  => $data->{algorithm},
#        bullbreese => $data->{bullbreese},
#        retention  => $data->{retention},
#    };
};

true;
