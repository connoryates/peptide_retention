package Peptide::Retention;
use Moose;

use API::X;
use Try::Tiny;
use Log::Any qw/$log/;
use List::Util qw(sum);
use InSilicoSpectro::InSilico::RetentionTimer;
use InSilicoSpectro::InSilico::RetentionTimer::Hodges;

my %BB_VALUES = (
    A => 0.610,
    R => 0.690,
    N => 0.890,
    D => 0.610,
    C => 0.360,
    Q => 0.970,
    E => 0.510,
    G => 0.810,
    H => 0.690,
    I => -1.450,
    L => -1.650,
    K => 0.460,
    M => -0.660,
    F => -1.520,
    P => -0.170,
    S => 0.420,
    T => 0.290,
    W => -1.200,
    Y => -1.430,
    V => -0.750,
);

has 'hodges' => (
    is      => 'ro',
    isa     => 'InSilicoSpectro::InSilico::RetentionTimer::Hodges',
    lazy    => 1,
    builder => '_build_hodges',
);

sub _build_hodges {
    return InSilicoSpectro::InSilico::RetentionTimer::Hodges->new;
}

sub tryptic {
    my ($self, $seq) = @_;

    if (not defined $seq) {
        API::X->throw({
            message => "Missing required param : seq",
        });
    }    

    $seq =~ s/\n//;
    my @tryptic = split(/(?!P)(?<=[RK])/, $seq);

    $log->warn("found " . @tryptic . " tryptic cleavage patterns");

    return \@tryptic;
}

sub tryptic_vals {
    my ($self, $peptide) = @_;

    if (not defined $peptide) {
        API::X->throw({
            message => "Missing required param : peptide",
        });
    }

    my $peptide_info;
    try {
        my $bb_vals      = $self->assign_bb_values($peptide);
           $peptide_info = $self->hodges_predict($peptide, $bb_vals);
    } catch {
        $log->warn("Cannot determine peptide info : $_");

        API::X->throw({
            message => "Cannot determine peptide info : $_",
        });
    };

    return $peptide_info;
}

sub hodges_predict {
    my ($self, $peptide, $bb_vals) = @_;

    if (not defined $peptide) {
        API::X->throw({
            message => "Missing required param : peptide",
        });
    }

    if (not defined $bb_vals and defined $peptide) {
        $bb_vals = $self->assign_bb_values($peptide);
    }

    my $ret;
    try {
        $ret = $self->hodges->predict(peptide => $peptide);
    } catch {
        $log->warn("Failed to get hodges prediction : $_");

        API::X->throw({
            message => "Failed to get hodges prediction : $_",
        });
    };

    return +{
        retention_info => {
            peptide            => $peptide,
            hodges_prediction  => $ret,
            bullbreese         => $bb_vals,
            length             => length($peptide),
        },
    };
}

sub assign_bb_values {
    my ($self, $seq) = @_;

    if (not defined $seq) {
        API::X->throw({
            message => "Missing required param : seq"
        });
    }

    my @bb_vals = grep { $_ } map { $BB_VALUES{$_} } split '', $seq;

    if (not @bb_vals or @bb_vals == 0) {
        API::X->throw({
            message => "Cannot determine bullbreese values for $seq",
        });
    }

    my $bb_vals = sum(@bb_vals);

    return $bb_vals;
}

__PACKAGE__->meta->make_immutable;

=pod

Peptide::Retention

Class to hold the methods for retention prediction

=head1 tryptic

Splits strings into their tryptic cleavage patterns

=head2 tryptic_vals

Sends the parsed sequences to assign Bull and Breese values and predict retention time

=head3 hodges_predict

Uses the Hodges algorithm to predict retention time of the input sequence

=head4 assign_bb_values

Assign the input sequence to their Bull and Breese values

=cut

1;
