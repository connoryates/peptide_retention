package Peptide::Config;
use Moose;

use YAML::XS 'LoadFile';

sub config {
    my $file   = "/home/pi/peptide_retention/environments/development.yml";
    my $config = LoadFile($file);

    return $config;
}

__PACKAGE__->meta->make_immutable;
