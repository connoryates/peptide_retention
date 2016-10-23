package Peptide::Config;
use Moose;

use YAML::XS 'LoadFile';
use FindBin qw/$RealBin/;

our $CONFIG;

sub config {
    my $self   = shift;

    my $root   = $self->_root;

    warn "ROOT => $root";

    my $file   = "/home/pi/peptide_retention/environments/development.yml";
    $CONFIG  ||= LoadFile($file);

    return $CONFIG;
}

sub _root {
    my $self = shift;

    my $root = "$RealBin/../../peptide_retention/environments";

    return $root;
}

__PACKAGE__->meta->make_immutable;

=pod

Peptide::Config

Class for retrieving configuration details

=head1 config

Reads the config file for environment set by PLACK_ENV when starting the app

=cut

1;
