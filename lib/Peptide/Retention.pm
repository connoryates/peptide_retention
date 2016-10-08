package Peptide::Retention;
use Moose;

use InSilicoSpectro::InSilico::RetentionTimer;
use InSilicoSpectro::InSilico::RetentionTimer::Hodges;
use Peptide::Model;

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

has 'timer' => (
    is      => 'ro',
    isa     => 'InSilicoSpectro::InSilico::RetentionTimer::Hodges',
    lazy    => 1,
    builder => '_build_timer',
    handles => [qw(predict)],
);

has 'model' => (
     is      => 'ro',
     isa     => 'Peptide::Model',
     lazy    => 1,
     builder => '_build_model',
);

sub _build_timer {
    return InSilicoSpectro::InSilico::RetentionTimer::Hodges->new;
}

sub _build_model {
    return Peptide::Model->new;
}

sub tryptic {
    my ($self, $seq) = @_;

    $seq =~ s/\n//;
    my @tryptic = split(/(?!P)(?<=[RK])/, $seq);
    warn "found " . @tryptic . " tryptic cleavage patterns\n";

    return \@tryptic;
}

sub tryptic_vals {
    my ($self, $seq) = @_;

    my $tryptic = $self->tryptic($seq);

    my %seq; 
    foreach my $tryptic (@$tryptic) {
        my $bb_vals = $self->assign_bb_values($tryptic);
        my $ret     = $self->retention($tryptic);

        # create_table($tryptic, $bb_vals, $ret);

        $seq{$tryptic}{bullbreese} = $bb_vals;
        $seq{$tryptic}{retention}  = $ret;
    }

    return \%seq;
}

sub assign_bb_values {
    my ($self, $seq) = @_;

    my @bb_vals = grep { $_ } map { $BB_VALUES{$_} } split '', $seq;

    return unless @bb_vals;

    my $bb_vals = sum(@bb_vals);

    return $bb_vals;
}

sub predict {
    my ($self, $sequence) = @_;

    return $self->timer->predict($sequence);
}

__PACKAGE__->meta->make_immutable;
