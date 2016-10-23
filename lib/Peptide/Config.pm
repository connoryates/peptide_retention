package Peptide::Config;
use Moose;

use YAML::XS 'LoadFile';
use FindBin qw/$RealBin/;

our $CONFIG;

sub config {
    my $self   = shift;
    my $root   = $self->_root;

    my $file   = $root . '/' . $ENV{PLACK_ENV} . '.yml';
    $CONFIG  ||= LoadFile($file);

    return $CONFIG;
}

sub _root {
    my $self = shift;
    my $root = "$RealBin/../environments";

    return $root;
}

__PACKAGE__->meta->make_immutable;

=pod

Peptide::Config

Class for retrieving configuration details

=head1 config

Reads the config file for environment set by PLACK_ENV when starting the app.

This method assumes you started the app from the bin/ dir. A more elegant
solution is needed for this

=cut

1;
