package API;
use Dancer ':syntax';

=head1

REST routes for handling peptide retention information

=cut

use API::Routes::Peptides;

=head1

REST routes for handling file uploads. Currently not in use

=cut

use API::Routes::Upload;

=head1

Health check and other main REST routes

=cut

use API::Routes::Main;

=head1

REST route for returning correlation data via HTTP requests

=cut

use API::Routes::Correlate;

=head1

REST routes for handling mass

=cut

use API::Routes::Mass;

=head1

Routes for rendering dashboard

=cut

use Dashboard::Routes::Main;



true;
