package Peptide::MolecularWeight;
use Moose;

use List::Util qw(sum);
use Log::Any qw/$log/;
use Try::Tiny;
use API::X;

my %WEIGHTS = (
   A => 71.09,  R => 16.19,  D => 114.11, N => 115.09,
   C => 103.15, E => 129.12, Q => 128.14, G => 57.05,
   H => 137.14, I => 113.16, L => 113.16, K => 128.17,
   M => 131.19, F => 147.18, P => 97.12,  S => 87.08,
   T => 101.11, W => 186.12, Y => 163.18, V => 99.14,
);

sub assign_molecular_weight {
    my ($self, $seq) = @_;

    if (not defined $seq) {
        API::X->throw({
            message => "Missing required param : seq",
        });
    }

    my $weight;
    try {
       my @seq = split //, $seq;
       my @amino_acids = keys %WEIGHTS;

       my @mapped;
       foreach my $s (@seq) {
           if ( not grep { /$s/ } @amino_acids ) {
               API::X->throw({
                  message => "$s is not a valid amino acid!",
               });
           }

           if ( my $w = $WEIGHTS{$s} ) {
               push @mapped, $w;
           }
           else {
               API::X->throw({
                  message => "Cannot find molecular weight for $_";
               });
           }
       }

       $weight = sum(@mapped);
    } catch {
        $log->warn("Could not determine molecular weight for $seq : $_");

        API::X->throw({
            message => "Could not determine molecular weight for $seq : $_",
        });
    };

    return $weight;
}

__PACKAGE__->meta->make_immutable;
