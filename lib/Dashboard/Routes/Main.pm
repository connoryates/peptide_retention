package Dashboard::Routes::Main;

use API::X;
use Dancer ':syntax';
use Dancer::Exception qw(:all);
use API::Plugins::Peptides;
use API::Plugins::CorrelateManager;

any '/' => sub {
    my %ret = ();
    try {
#        $data = peptide_manager()->get_all({
#            filter => {
#                length => 27,
#            },
#        });

        $ret{curr_corr} = correlate_manager()->correlate_peptides({
            algorithm => 'hodges',
        });

        my $counts = peptide_manager()->counts;
        $ret{$_} = $counts->{$_} for keys %$counts;
    } catch {
        API::X->throw({
            message => "Failed to get correlation data: $_",
            code    => 500,
        });
    };

    template 'templates/dashboard.tt', \%ret;
};

true;

=pod

=head1 DESCRIPTION

    Home page for dashboard

=cut
