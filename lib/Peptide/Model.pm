package Peptide::Model;
use Moose;

use Peptide::Schema;
use Peptide::Retention;
use Try::Tiny;

has 'schema' => (
    is      => 'ro',
    isa     => 'Peptide::Schema',
    lazy    => 1,
    builder => '_build_schema',
);

has 'retention' => (
    is      => 'ro',
    isa     => 'Peptide::Retention',
    lazy    => 1,
    builder => '_build_retention',
);

sub _build_schema {
    return Peptide::Schema->new;
}

sub _build_retention {
    return Peptide::Retention->new;
}

sub get_retention_info {
    my ($self, $peptide) = @_;

    my $data = $self->schema->uniprot_yeast->search({ peptide => $peptide });

    return $self->_get_retention_info($peptide) unless defined $data->{_column_data};

    return $data->{_columns};
}

sub _get_retention_info {
    my ($self, $peptide) = @_;

    my $info = $self->retention->tryptic_vals($peptide);

    try {
        $self->add_retention_info($info);
    } catch {
        warn "Could not add $peptide to database : $_";
    };

    return $info;
}

sub add_retention_info {
    my ($self, $info) = @_;

    die "No retention info key detected" unless defined $info->{retention_info};

    my $algorithm = $info->{retention_info}->{prediction_algorithm} . "_prediction";

    my $ret = $info->{retention_info};

    my $insert = {
        $algorithm => $ret->{predicted_retention},
        bullbreese => $ret->{bullbreese},
        peptide    => $ret->{peptide},
    };

    return $self->schema->uniprot_yeast->create($insert);
}

sub get_bb_retention_correlation_data {
    my $self = shift;

    my $rs = $self->schema->uniprot_yeast->search({});

    my @bullbreese = ();
    my @retention  = ();


    while (my $val = $rs->next) {
        my $peptide = $val->{_column_data};

        push @bullbreese, $peptide->{bullbreese};
        push @retention, $peptide->{hodges_prediction};
    }

    return +{
        bullbreese => \@bullbreese,
        retention  => \@retention
    };
}

sub get_peptide_retention_correlation_data {
    my $self = shift;

    my $rs   = $self->schema->uniprot_yeast->search({});

    my @peptide_lengths = ();
    my @retention       = ();

    while (my $val  = $rs->next) {
        my $peptide = $val->{_column_data};

        push @peptide_lengths, length( $peptide->{peptide} );
        push @retention, $peptide->{hodges_prediction};
    }

    return +{
        peptide_lengths => \@peptide_lengths,
        retention       => \@retention
    };

}

sub get_peptide_retention_filtered_data {
    my ($self, $filter) = @_;

    warn "MODEL";

    die "Argument filter must be a HashRef"
      unless ref($filter) and ref($filter) eq 'HASH';

    # There's only one key, don't worry
    my $filter_type = [keys %$filter]->[0];

    # TODO: support more than one filter type
    die unless defined $filter_type or $filter_type !~ /peptide_length/;

    # TODO: add filters to queries instead of filtering in memory
    my $rs = $self->schema->uniprot_yeast->search({});

    my @bullbreese     = ();
    my @retention_info = ();

    while (my $val  = $rs->next) {
        my $peptide = $val->{_column_data};

        if (length($peptide->{peptide}) == $filter->{peptide_length}) {
            push @bullbreese, $peptide->{bullbreese};
            # TODO: Support algorithm filters
            push @retention_info, $peptide->{hodges_prediction};
        }
    }

    return +{
        retention_info => \@retention_info,
        bullbreese     => \@bullbreese,
    };
}

sub get_bar_chart_peptide_data {
    my ($self, $peptide) = @_;

    my $peptide_data = $self->schema->uniprot_yeast({ peptide => $peptide });

    die "Cannot find peptide data" unless defined $peptide->{_column_data};

    return $peptide_data->{_column_data};
}

sub validate_api_key {
    return 1;
}

__PACKAGE__->meta->make_immutable;

=pod

Peptide::Model

Class to handle database queries

=head1 get_retention_info

Queries the database for the given peptide input

=head2 add_retention_info

Adds the given peptide input and retention info to the database

=head3 get_bb_retention_correlation_data 

Queries the database for all peptides and returns a HashRef with
an ArrayRef of all Bull and Breese values and an ArrayRef of all
retention info

=head4 get_peptide_length_retention_correlation_data 

Queries the database for all peptides and returns a HashRef with
an ArrayRef of all peptide lengths and an ArrayRef of all retention
info

CAUTION: these methods hold all database values in memory,
caching solution coming

=head5 get_bar_chart_peptide_data

Future front-end query for displaying bar chart data in D3.js

=head6 get_peptide_retention_filtered_data

Return a correlation data structure with specified filters

=cut
