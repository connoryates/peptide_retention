package API;
use Dancer ':syntax';

=head1

REST routes for handling peptide retention information

=cut

use API::Routes::Peptides;

=head2

REST routes for handling file uploads. Currently not in use

=cut

use API::Routes::Upload;

=head3

Health check and other main REST routes

=cut

use API::Routes::Main;

=head4

REST route for returning correlation data via HTTP requests

=cut

use API::Routes::Correlate;


=head5

Future routes for charting data

=cut

use Dashboard::Routes::Chart;


true;
