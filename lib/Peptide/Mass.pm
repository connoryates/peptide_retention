package Peptide::Mass;
use Moose;

use API::X;
use Try::Tiny;
use List::Util qw(sum);

has nterm => (
    is      => 'rw',
    default => sub { 1.007825 }
);

has cterm => (
    is      => 'rw',
    default => sub { 17.00274 }
);

has term_gain => (
    is      => 'rw',
    default => sub {
        my $self = shift;
        return $self->nterm + $self->cterm;
    }
);

my %MASS = (
      'S' => {
               'monoisotopic' => '87.03203',
               'average' => '87.0782',
               'cterm' => '3.55',
               'nterm' => '6.93'
             },
      'F' => {
               'monoisotopic' => '147.06841',
               'average' => '147.1766',
               'cterm' => '3.55',
               'nterm' => '7.50'
             },
      'T' => {
               'monoisotopic' => '101.04768',
               'average' => '101.1051',
               'cterm' => '3.55',
               'nterm' => '6.82'
             },
      'N' => {
               'monoisotopic' => '114.04293',
               'average' => '114.1038',
               'cterm' => '3.55',
               'nterm' => '7.50'
             },
      'K' => {
               'monoisotopic' => '128.09496',
               'average' => '128.1741',
               'cterm' => '3.55',
               'nterm' => '7.50'
             },
      'Y' => {
               'monoisotopic' => '163.06333',
               'average' => '163.1760',
               'cterm' => '3.55',
               'nterm' => '7.50'
             },
      'E' => {
               'monoisotopic' => '129.04259',
               'average' => '129.1155',
               'cterm' => '4.75',
               'nterm' => '7.70'
             },
      'V' => {
               'monoisotopic' => '99.06841',
               'average' => '99.1326',
               'cterm' => '3.55',
               'nterm' => '7.44'
             },
      'Q' => {
               'monoisotopic' => '128.05858',
               'average' => '128.1307',
               'cterm' => '3.55',
               'nterm' => '7.50'
             },
      'M' => {
               'monoisotopic' => '131.04049',
               'average' => '131.1926',
               'cterm' => '3.55',
               'nterm' => '7.00'
             },
      'C' => {
               'monoisotopic' => '103.00919',
               'average' => '103.1388',
               'cterm' => '3.55',
               'nterm' => '7.50'
             },
      'L' => {
               'monoisotopic' => '113.08406',
               'average' => '113.1594',
               'cterm' => '3.55',
               'nterm' => '7.50'
             },
      'A' => {
               'monoisotopic' => '71.03711',
               'average' => '71.0788',
               'cterm' => '3.55',
               'nterm' => '7.59'
             },
      'W' => {
               'monoisotopic' => '186.07931',
               'average' => '186.2132',
               'cterm' => '3.55',
               'nterm' => '7.50'
             },
      'P' => {
               'monoisotopic' => '97.05276',
               'average' => '97.1167',
               'cterm' => '3.55',
               'nterm' => '8.36'
             },
      'H' => {
               'monoisotopic' => '137.05891',
               'average' => '137.1411',
               'cterm' => '3.55',
               'nterm' => '7.50'
             },
      'D' => {
               'monoisotopic' => '115.02694',
               'average' => '115.0886',
               'cterm' => '4.55',
               'nterm' => '7.50'
             },
      'R' => {
               'monoisotopic' => '156.10111',
               'average' => '156.1875',
               'cterm' => '3.55',
               'nterm' => '7.50'
             },
      'I' => {
               'monoisotopic' => '113.08406',
               'average' => '113.1594',
               'cterm' => '3.55',
               'nterm' => '7.50'
             },
      'G' => {
               'monoisotopic' => '57.02146',
               'average' => '57.0519',
               'cterm' => '3.55',
               'nterm' => '7.50'
             }
);

sub assign_mass {
    my ($self, $sequence) = @_;

    API::X->throw({
        message => "Missing required param : sequence",
    }) unless $sequence;

    return {
        average      => $self->average_mass($sequence),
        monoisotopic => $self->monoisoptoic_mass($sequence),
    };
}

sub average_mass {
    my ($self, $sequence) = @_;

    API::X->throw({
        message => "Missing required param : sequence"
    }) unless $sequence;

    my @vals = map { $MASS{$_}->{average} } split //, $sequence;

    my $mass;
    try {
        $mass = sum(@vals);
    } catch {
        API::X->throw({
            message => "Failed to get mass : $_",
        });
    };

    my $correct = $self->term_gain + $mass;
    return sprintf("%0.5f", $correct);
}

sub monoisotopic_mass {
    my ($self, $sequence) = @_;

    API::X->throw({
        message => "Missing required param : sequence"
    }) unless $sequence;

    my @vals = map { $MASS{$_}->{monoisotopic} } split //, $sequence;

    my $mass;
    try {
        $mass = sum(@vals);
    } catch {
        API::X->throw({
            message => "Failed to get mass : $_",
        });
    };

    my $correct = $self->term_gain + $mass;
    return sprintf("%0.5f", $correct);
}

__PACKAGE__->meta->make_immutable;
