package Peptide::Model;
use Moose;

use Peptide::MolecularWeight;
use Peptide::Retention;
use Log::Any qw/$log/;
use API::Cache::Model;
use Peptide::Schema;
use Peptide::Util;
use Try::Tiny;
use API::X;

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
    handles => [qw(assign_bb_values)],
);

has 'molecular_weight' => (
    is      => 'ro',
    isa     => 'Peptide::MolecularWeight',
    lazy    => 1,
    builder => '_build_molecular_weight',
    handles => [qw(assign_molecular_weight)],
);

has 'util' => (
    is      => 'ro',
    isa     => 'Peptide::Util',
    lazy    => 1,
    builder => '_build_util',
    handles => [qw(hash_merge merge_if_different)],
);

has 'cache' => (
    is      => 'ro',
    isa     => 'API::Cache::Model',
    lazy    => 1,
    builder => '_build_cache',
    handles => [qw(get_model_cache set_model_cache)],
);

sub _build_schema {
    return Peptide::Schema->new;
}

sub _build_retention {
    return Peptide::Retention->new;
}

sub _build_molecular_weight {
    return Peptide::MolecularWeight->new;
}

sub _build_util {
    return Peptide::Util->new;
}

sub _build_cache {
    return API::Cache::Model->new;
}

sub get_retention_info {
    my ($self, $peptide) = @_;

    if (not defined $peptide) {
        API::X->throw({
           message => "Missing required param : peptide",
        });
    }

    my $peptide_obj = $self->schema->peptide;

    $peptide_obj->result_class('DBIx::Class::ResultClass::HashRefInflator');

    my $data;
    try {
        $data = $peptide_obj->find(
            {
                sequence => $peptide,
            },
            {
                prefetch => [
                    'proteins',
                    'predictions',
                    { 
                        proteins => { protein_sequences => 'protein_descriptions' },
                    },
                ],
            },
        );
    } catch {
        API::X->throw({
            message => "Failed to ge retention info : $_",  
        });
    };

    return $self->_get_retention_info($peptide) unless defined $data;

    return $data;
}

sub _get_retention_info {
    my ($self, $peptide) = @_;

    if (not defined $peptide) {
        API::X->throw({
            message => "Missing required param : peptide",
        });
    }

    my ($info, $update);
    try {
        $info = $self->retention->tryptic_vals($peptide);

        $log->info("Adding retention info : $info");
        $update = $self->add_retention_info($info);
    } catch {
        $log->warn("Could not add $peptide to database : $_");
    };

    if (defined $update) {
        $info = $self->get_associated_proteins($peptide);

        my $peptide_obj = $self->schema->peptide;
        $peptide_obj->result_class('DBIx::Class::ResultClass::HashRefInflator');

        my $predictions = $peptide_obj->find(
            { sequence => $peptide },
            { prefetch => [ 'predictions' ] },
        );

        $info = $self->hash_merge($info, $predictions);
    }

    return $info;
}

sub get_associated_proteins {
    my ($self, $peptide) = @_;

    if (not defined $peptide) {
        API::X->throw({
            message => "Missing required param : peptide",
        });
    }

    my $peptide_obj = $self->schema->peptide;
    $peptide_obj->result_class('DBIx::Class::ResultClass::HashRefInflator');

    my $data;
    try {
        $data = $peptide_obj->find(
            { sequence => $peptide },
            {
                prefetch => {
                    proteins => {
                        protein_sequences => 'protein_descriptions'
                    }
                }
            },
        );
    } catch {
        API::X->throw({
            message => "Failed to get associated proteins : $_",
        });
    };

    return $data;
}

sub add_retention_info {
    my ($self, $info) = @_;

    if (!ref($info) or ref($info) ne 'HASH') {
        API::X->throw({
            message => "Argument info must be a HashRef",
        });
    }

    if (not defined $info->{retention_info}) {
        API::X->throw({
            message => "Missing required arg : retention_info",
        });
    }

    my $ret = $info->{retention_info};

    my $protein_info = $info->{protein_info} // undef;
    my $prediction   = $info->{prediction_info} // undef;

    my @predicted_retentions;

    if (defined $prediction and ref($prediction) and ref($prediction) eq 'ARRAY') {
        unless (grep { /hodges/ } map { $_->{algorithm} } @$prediction) {
            push @predicted_retentions, {
                algorithm      => 'hodges',
                predicted_time => $self->retention->hodges->predict(peptide => $ret->{sequence}),
            };
        }
    }
    elsif (defined $prediction and ref($prediction) and ref($prediction) eq 'HASH') {
        if ($prediction->{algorithm} ne 'hodges') {
            push @predicted_retentions, {
                algorithm       => 'hodges',
                predicted_time => $self->retention->hodges->predict(peptide => $ret->{sequence}),
            };
        }

        push @predicted_retentions, {
            algorithm      => $prediction->{algorithm},
            predicted_time => $prediction->{prediction},
       };
    }
    else {
        push @predicted_retentions, {
            algorithm       => 'hodges',
            predicted_time => $self->retention->hodges->predict(peptide => $ret->{sequence}),
        };
    }

    if (not defined $ret->{sequence} and not defined $ret->{sequence}) {
        API::X->throw({
            message => "Missing reqired retention_info param : $ret->{sequence}",
        });
    }

    if (not defined $ret->{bullbreese}) {
        try {
            $ret->{bullbreese} = $self->assign_bb_values($ret->{sequence});
        } catch {
            API::X->throw({
                message => "Failed to assign bullbreese values : $_",
            });
        };
    }

    if (not defined $ret->{molecular_weight}) {
       try {
           $ret->{molecular_weight} = $self->assign_molecular_weight($ret->{sequence});
       } catch {
           API::X->throw({
               message => "Failed to assign molecular weight : $_",
           });
       };
    }

    my $payload = {
        cleavage            => $ret->{cleavage},
        molecular_weight    => $ret->{molecular_weight},
        bullbreese          => $ret->{bullbreese},
        sequence            => $ret->{sequence},
        length              => length( $ret->{sequence} ),
        real_retention_time => $ret->{real_retention_time} // undef,
    };

    my $status;
    try {
        if (defined $protein_info and @predicted_retentions) {
            my $txn = $self->schema->txn_scope_guard;       
 
            my $peptide_obj  = $self->schema->peptide->find({ sequence => $payload->{sequence} });

            if (defined $peptide_obj and defined $peptide_obj->{_column_data}) {
                my $combined = $self->merge_if_different($payload, $peptide_obj->{_column_data});
                $peptide_obj = $peptide_obj->update($combined);

                $peptide_obj->update;
            }

            if (not defined $peptide_obj) {
                $peptide_obj = $self->schema->peptide->create($payload);

                $peptide_obj->update;
            }

            my $peptide_id = $peptide_obj->{_column_data}->{id};

            my $seq_obj    = $self->schema->protein_sequence->find({
                sequence   => $protein_info->{sequence},
                primary_id => $protein_info->{primary_id},
            });

            if (not defined $seq_obj) {
                 $seq_obj = $self->schema->protein_sequence->create({
                     sequence   => $protein_info->{sequence},
                     primary_id => $protein_info->{primary_id},
                 });

                 $seq_obj->update;
            }

            my $seq_id = $seq_obj->{_column_data}->{id};

            my $protein_obj  = $self->schema->protein->find({
                peptide_id   => $peptide_id,
                sequence_id  => $seq_id,
            });

            if (not defined $protein_obj) {
                $protein_obj = $self->schema->protein->create({
                    peptide_id  => $peptide_id,
                    sequence_id => $seq_id,
                });

                $protein_obj->update;
            }

            my $protein_id = $protein_obj->{_column_data}->{id};

            my $desc_obj   = $self->schema->protein_description->find({
                primary_id => $protein_info->{primary_id},
            });

            if (not defined $desc_obj) {
                $desc_obj = $self->schema->protein_description->create({
                    primary_id  => $protein_info->{primary_id},
                    description => $protein_info->{description},
                });

                $desc_obj->update;
            }

            if (@predicted_retentions) {
                foreach my $pr (@predicted_retentions) {
                    my $prediction_obj  = $self->schema->prediction->find({
                         algorithm      => $pr->{algorithm},
                         predicted_time => $pr->{predicted_time},
                         peptide_id     => $peptide_id,
                    });

                    if (not defined $prediction_obj) {
                        $prediction_obj    = $self->schema->prediction->create({
                            algorithm      => $pr->{algorithm},
                            predicted_time => $pr->{predicted_time},
                            peptide_id     => $peptide_id,
                        });

                        $prediction_obj->update;
                    }
                }
            }

            $status = $txn->commit;
        }
        else {
            $status = $self->schema->peptide->find_or_create($payload);
        }
    } catch {
        API::X->throw({
            message => "Could not add payload to database : $_",
        });
    };

    return $status;
}

sub get_bb_retention_correlation_data {
    my $self = shift;

    my $rs;
    try {
        $rs = $self->schema->peptide->search({})
    } catch {
        API::X->throw({
            message => "Failed to get correlation data : $_",
        });
    };

    my @correlation_data = ();;

    while (my $val  = $rs->next) {
        my $peptide = $val->{_column_data};

        next unless defined $peptide;

        my @predictions;
        try {
            my $peptide_id = $peptide->{id};
            @predictions   = map { $_->{_column_data} }
              $self->schema->prediction->search({ peptide_id => $peptide_id });
        } catch {
            $log->warn("Failed to get predictions for : $peptide");
        };

        next unless @predictions;

        push @correlation_data, {
            bullbreese  => $peptide->{bullbreese},
            predictions => \@predictions,
        };
    }

    return \@correlation_data;
}

sub get_peptide_retention_correlation_data {
    my $self = shift;

    my $rs;
    try {
        $rs = $self->schema->peptide->search({});
    } catch {
        API::X->throw({
            message => "Failed to get correlation data : $_",
        });
    };

    my @correlation_data = ();

    while (my $val  = $rs->next) {
        my $peptide = $val->{_column_data};

        next unless defined $peptide;

        my @predictions;
        try {
            my $peptide_id  = $peptide->{id};
            @predictions = map { $_->{_column_data} }
              $self->schema->prediction->search({ peptide_id => $peptide_id });
        } catch {
            $log->warn("Failed to get predictions for : $peptide");
        };

        next unless @predictions;

        push @correlation_data, {
            length      => $peptide->{length},
            predictions => \@predictions,
        };
    }

    return \@correlation_data;
}

sub get_peptide_retention_filtered_data {
    my ($self, $filter) = @_;

    if (not defined $filter) {
        API::X->throw({
            message => "Missing required param : filter",
        });
    }

    if (!ref($filter) or ref($filter) ne 'HASH') {
        API::X->throw({
            message => "Param filter must be a HashRef",
        });
    }

    foreach my $required (qw(filter data)) {
        if (not defined $filter->{$required}) {
            API::X->throw({
                message => "Missing required arg : $required",
            });
        }
    }

    my $filter_type = $filter->{filter};
    my $filter_data = $filter->{data};

    # TODO: support more than one filter type
    if (not defined $filter_type or $filter_type !~ /peptide_length/) {
        API::X->throw({
            message =>  "Unknown or unsupported filter type",
        });
    }

    my $method = '_' . $filter_type . '_filter';

    my $correlation_data;
    try {
        $correlation_data = $self->$method($filter_data);
    } catch {
        API::X->throw({
            message => "Failed to get filter data : $_",
        });
    };

    return $correlation_data;
}

sub _peptide_length_filter {
    my ($self, $peptide_filter_length) = @_;

    if (not defined $peptide_filter_length) {
        API::X->throw({
            message => "Missing required arg : peptide_filter_length",
        });
    }

    my $rs;
    try {
        $rs = $self->schema->peptide->search({
           length => "$peptide_filter_length",
        });
    } catch {
        $log->warn("Failed to get peptide filter length data for filter length : $peptide_filter_length : $_");
        API::X->throw({
            message => "Failed to get peptide filter length data : $_",
        });
    };

    my @correlation_data = ();

    my $cursor = $rs->cursor;

    while (my @peptides = $cursor->next) {
        my $pred_obj;
        try {
            $pred_obj = $self->schema->prediction->search({
                peptide_id => $peptides[0],
            });
        } catch {
            API::X->throw({
               message => "Failed to get prediction data : $_",
            });
        };

        my $cursor = $pred_obj->cursor;

        while (my @predictions = $cursor->next) {
            push @correlation_data, {
                bullbreese  => $peptides[3],
                predictions => $predictions[3],
            };
        }
    }

    return \@correlation_data;
}

sub get_bar_chart_peptide_data {
    my ($self, $peptide) = @_;

    if (not defined $peptide) {
        API::X->throw({
            message => "Missing required param : peptide",
        });
    }

    my ($peptide_data, $column_data);
    try {
        my $peptide_obj  = $self->schema->peptide;
           $peptide_obj->result_class('DBIx::Class::ResultSet::HashRefInflator');
           $peptide_data = $peptide_obj->find({ peptide => $peptide });
    } catch {
        API::X->throw({
            message => "Cannot find peptide data for peptide $peptide : $_",
        });
    };

    return $peptide_data;
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
