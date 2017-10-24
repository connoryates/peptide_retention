package Peptide::Model;
use Moose;

use Peptide::MolecularWeight;
use List::Util qw(first);
use Peptide::Retention;
use API::Elasticsearch;
use Log::Any qw/$log/;
use API::Cache::Model;
use Peptide::Schema;
use Peptide::Util;
use Peptide::Mass;
use Try::Tiny;
use API::X;

my $GAIN      = 0.001;
my $CONF      = 100;
my $RECURSION = 0;

has gain => (
    is      => 'rw',
    isa     => 'Num',
    default => 0.001,
    trigger => sub {
        my ($self, $gain) = @_;
        $GAIN = $gain;
    }
);

has heuristic => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has recursion_limit => (
    is      => 'ro',
    isa     => 'Int',
    default => sub { 10 }
);

has schema => (
    is      => 'ro',
    isa     => 'Peptide::Schema',
    lazy    => 1,
    builder => '_build_schema',
);

has retention => (
    is      => 'ro',
    isa     => 'Peptide::Retention',
    lazy    => 1,
    builder => '_build_retention',
    handles => [qw(assign_bb_values)],
);

has molecular_weight => (
    is      => 'ro',
    isa     => 'Peptide::MolecularWeight',
    lazy    => 1,
    builder => '_build_molecular_weight',
    handles => [qw(assign_molecular_weight)],
);

has util => (
    is      => 'ro',
    isa     => 'Peptide::Util',
    lazy    => 1,
    builder => '_build_util',
    handles => [qw(hash_merge merge_if_different ensure_integer to_one)],
);

has cache => (
    is      => 'ro',
    isa     => 'API::Cache::Model',
    lazy    => 1,
    builder => '_build_cache',
    handles => [qw(get_model_cache set_model_cache)],
);

has elastic => (
    is      => 'ro',
    isa     => 'API::Elasticsearch',
    lazy    => 1,
    builder => '_build_elastic',
);

has mass => (
    is      => 'ro',
    isa     => 'Peptide::Mass',
    lazy    => 1,
    builder => '_build_mass',
    handles => [qw(average_mass monoisotopic_mass)],
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

sub _build_elastic {
    return API::Elasticsearch->new;
}

sub _build_mass {
    return Peptide::Mass->new;
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
            { sequence => $peptide },
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
            message => "Failed to get retention info : $_",  
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

    API::X->throw({
        message => "Missing required param : peptide",
    }) unless $peptide;

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

sub get_all_peptides {
    my ($self, $args) = @_;

    my $payload = $args->{length}
        ? { length => $args->{length} }
        : {};

    my @peptides;
    try {
        my $dbh = $self->schema->dbh;

        my $sql = <<SQL;
        SELECT * FROM peptides p
            JOIN predictions pr
                ON pr.peptide_id = p.id
                    WHERE p.length = ?
            
SQL

        my $sth = $dbh->prepare($sql);
           $sth->execute($args->{length});

        while (my $row = $sth->fetchrow_hashref) {
            push @peptides, $self->ensure_integer($row);
        }
    } catch {
        API::X->throw({
            message => "Failed to get peptides: $_",
        });
    };

    return \@peptides;
}

sub search_peptides {
    my ($self, $args) = @_;

    API::X->throw({
        message => 'Missing requried arg : $args',
    }) unless $args;

    my $keywords = $args->{keywords} || undef;
    my %payload  = (
        primary_ids => [],
    );

    if ($keywords) {
        my $search_results = $self->elastic->search_peptide({
            keywords => $keywords,
        });

        if ($search_results) {
            for (@{$search_results->{hits}->{hits}}) {
                push @{$payload{primary_ids}}, $_->{_id};
            }
        }
    }

    my $payload = $self->hash_merge(\%payload, $args);

    my @results = ();
    try {
        my $sql = $self->_format_search($payload);
        my $dbh = $self->schema->dbh;
        my $sth = $dbh->prepare($sql);

        my $exec = $self->_format_search_exec($payload);

        $sth->execute(@$exec);

        while (my $row = $sth->fetchrow_hashref) {
            push @results, $row;
        }
    } catch {
        $log->warn("Failed to search peptides: $_");

        API::X->throw({
            message => "Failed to search peptides: $_",
        });
    };

    return \@results;
}

sub _format_search {
    my ($self, $args) = @_;

    API::X->throw({
        message => 'Missing required arg : args',
    }) unless $args;

    my $sql = <<SQL;
    SELECT
        ps.sequence as protein_sequence,
        pr.algorithm,
        p.molecular_weight,
        pr.predicted_time,
        p.length,
        p.sequence,
        p.bullbreese,
        p.real_retention_time,
        p.cleavage,
        ps.primary_id
    FROM peptides p
SQL

    if ($args->{primary_ids} and @{$args->{primary_ids}}
        and first { $_ } @{$args->{primary_ids}}) {
        my $join = <<JOIN;
            JOIN predictions pr
                ON pr.peptide_id = p.id
            JOIN proteins pro
                ON pro.peptide_id = p.id
            JOIN protein_sequences ps
                ON ps.id = pro.sequence_id
                    WHERE EXISTS (SELECT id FROM protein_sequences WHERE primary_id IN (
JOIN

        chomp($join);
        $join .= " ?," for @{$args->{primary_ids}};
        $join =~ s{,$}{};
        $join .= "))";

        if ($args->{length}) {
            my $where = q| AND p.length = ?|;

            $join .= $where;
        }

        $sql .= $join;
    }

    $sql .= ' OFFSET ' . $args->{offset} if $args->{offset};
    $sql .= ' LIMIT ' . $args->{limit} if $args->{limit};

    return $sql;
}

sub _format_search_exec {
    my ($self, $args) = @_;

    API::X->throw({
        message => 'Missing required arg : args',
    }) unless $args;

    my @exec = ();
    if (first { $_ } @{$args->{primary_ids}}) {
        push @exec, @{$args->{primary_ids}};
    }

    push @exec, $args->{length} if $args->{length};

    return \@exec;
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

    if (not $ret->{bullbreese}) {
        try {
            $ret->{bullbreese} = $self->assign_bb_values($ret->{sequence});
        } catch {
            API::X->throw({
                message => "Failed to assign bullbreese values : $_",
            });
        };
    }

    if (not $ret->{molecular_weight}) {
       try {
           $ret->{molecular_weight} = $self->assign_molecular_weight($ret->{sequence});
       } catch {
           API::X->throw({
               message => "Failed to assign molecular weight : $_",
           });
       };
    }

    if (not $ret->{average_mass}) {
        $ret->{average_mass} = $self->average_mass($ret->{sequence});
    }

    if (not $ret->{monoisotopic_mass}) {
        $ret->{monoisotopic_mass} = $self->monoisotopic_mass($ret->{sequence});
    }

    my $payload = {
        cleavage            => $ret->{cleavage},
        molecular_weight    => $ret->{molecular_weight},
        bullbreese          => $ret->{bullbreese},
        sequence            => $ret->{sequence},
        length              => length( $ret->{sequence} ),
        real_retention_time => $ret->{real_retention_time} // undef,
        average_mass        => $ret->{average_mass},
        monoisotopic_mass   => $ret->{monoisotopic_mass},
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

            # TODO: remove unique index on primary key
            if (not defined $desc_obj) {
                my $desc_obj = $self->schema->protein_description->create({
                    primary_id  => $protein_info->{primary_id},
                    description => $protein_info->{description},
                });

                $desc_obj->update;

                my ($title) = $protein_info->{primary_id} =~ /^.+\|.+\|(.+)$/;

                $self->elastic->index_peptide({
                    title      => $title,
                    primary_id => $protein_info->{primary_id},
                    body       => $protein_info->{description},
                });
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

sub correlate_data {
    my ($self, $args) = @_;

    if (not $args) {
        API::X->throw({
            message => 'Missing args',
        });
    }

    my $dbh    = $self->schema->dbh;
    my $filter = $args->{filter};

    my $sql = $self->_format_correlate_sql($filter);

    my $corr;
    try {
        my $sth = $dbh->prepare($sql);

        $filter->{length} ? $sth->execute($filter->{length}) : $sth->execute;

        ($corr) = $sth->fetchrow_array;
    } catch {
        $log->warn("Failed to correlate data sets: $_");

        API::X->throw({
            message => "Failed to correlate data sets: $_",
        });
    };

    return $corr;
}

sub _format_correlate_sql {
    my ($self, $filter) = @_;

    my $alg = $filter->{algorithm};

    my $sql;
    if ($alg =~ /hodges/) {
        $sql = <<SQL;
            SELECT corr(p.bullbreese, pr.predicted_time)
                FROM peptides p
                    JOIN predictions pr
                        ON p.id = pr.peptide_id
SQL

        if ($filter->{length}) {
            $sql .= <<LENGTH;
                WHERE
                    p.length = ?
LENGTH
        }
    }
    else {
        API::X->throw({
            message => 'Unsupported algorithm filter.',
        });
    }

    return $sql;
}

sub get_protein_count { shift->get_count('protein') }
sub get_peptide_count { shift->get_count('peptide') }

sub get_count {
    my ($self, $table) = @_;

    my $count;
    try {
        my $t = $self->schema->$table;
           $count = $t->count;
    } catch {
        API::X->throw({
            message => "Failed to get table count : $_",
        });
    };

    return $count;
}

sub search_mass {
    my ($self, $args) = @_;

    API::X->throw({
        message => 'Missing required arg : args',
    }) unless $args;

    if (not $args->{average} xor $args->{monoisotopic}) {
        API::X->throw({
            message => 'Missing required arg : mass_type',
        });
    }

    my ($mass, $mass_type, $data);
    try {
        if ($args->{average}) {
            $mass_type = 'average_mass',
            $mass      = $args->{average};
        }
        elsif ($args->{monoisotopic}) {
            $mass_type = 'monoisotopic_mass',
            $mass      = $args->{monoisotopic};
        }

        $data = $self->schema->peptide->find({
            $mass_type => $mass,
        });
    } catch {
        API::X->throw({
            message => "Failed to search mass : $_",
        });
    };

    my $heuristic_args = {
        mass_type => $mass_type,
        mass      => $mass,
    };

    my $ret = $data->{_column_data};

    if (not $ret and $self->heuristic) {
        $ret = $self->_heuristic_search($heuristic_args);
    }

    if ($CONF > 0 and $ret->{sequence}) {
        $ret->{confidence} = $CONF . '%';
    }

    $self->_reset_mass_search;

    return $ret;
}

sub _reset_mass_search {
    my $self = shift;

    $GAIN      = 0;
    $CONF      = 100;
    $RECURSION = 0;
}

sub _adjust_conf {
    my $self = shift;
    my $gain = $self->gain;

    my $limit = $GAIN > $gain
        ? 5 * ($gain * $self->to_one($gain))
        : 1;

    return $limit;
}

sub _heuristic_search {
    my ($self, $args) = @_;

    return unless $CONF > 0;

    my $best;
    try {
        my $dbh = $self->schema->dbh;
        my $sql = $self->_format_heuristic($args->{mass_type});
        my $sth = $dbh->prepare($sql);

        my $mass  = $args->{mass};

        my $ceil  = $mass + $self->gain;
        my $floor = $mass - $self->gain;

        my $limit = 1;
        # my $limit = $self->_heuristic_limit;

        $CONF -= $self->_adjust_conf;
        $limit = int($limit);

        my @prepare = map { $self->ensure_integer($_) }
            ($floor, $ceil, $mass, $limit);

        $sth->execute(@prepare);

        while (my $row = $sth->fetchrow_hashref) {
            if ($row->{sequence}) {
                $best = $row;
                last;
            }
            else {
                $CONF -= 1;
            }
        }
    } catch {
        API::X->throw({
            message => "Failed to get heuristic results : $_",
        });
    };

    if (not $best or not $best->{sequence}) {
        $self->_increase_gain;
        $RECURSION++;

        return $self->_heuristic_search($args)
            unless $self->recursion_limit <= $RECURSION;
    }

    return $best;
}

sub _increase_gain {
    return $GAIN + shift->gain;
}

sub _format_heuristic {
    my ($self, $mass_type) = @_;

    my $sql = qq{
        SELECT * FROM peptides
            WHERE
                $mass_type >= ?
                AND
                $mass_type <= ?
            ORDER BY abs(?)
            LIMIT ?
    };

    return $sql;
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

=head1 add_retention_info

Adds the given peptide input and retention info to the database

=head1 get_bar_chart_peptide_data

Future front-end query for displaying bar chart data in D3.js

=cut
