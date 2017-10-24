package API::Elasticsearch;
use Moose;

use Search::Elasticsearch;
use Try::Tiny;
use DateTime;
use API::X;

has elastic => (
    is      => 'ro',
    isa     => 'Search::Elasticsearch::Client::5_0::Direct',
    lazy    => 1,
    builder => '_build_elastic',
);

sub _build_elastic {
    return Search::Elasticsearch->new;
}

sub search_peptide {
    my ($self, $args) = @_;

    if (not defined $args) {
        API::X->throw({
            message => "Missing required arg : args",
        });
    }

    my $keywords = $args->{keywords};

    if (not defined $keywords) {
        API::X->throw({
            message => "Missing required arg key : keywords",
        });
    }

    my $results;
    try {
        $results = $self->elastic->search(
            index => 'peptide_retention',
            body  => {
                query => {
                    match => { body => $keywords },
                }
            },
        );
    } catch {
        API::X->throw({
            message => "Failed to send query to elasticsearch index peptide_retention : $_",
        });
    };

    return $results;
}

sub index_peptide {
    my ($self, $info) = @_;

    if (not defined $info) {
        API::X->throw({
            message => "Missing required arg : info",
        });
    }

    if (!ref($info) or ref($info) ne 'HASH') {
        API::X->throw({
            message => "Arg info must be a HashRef",
        });
    }

    use Data::Dumper;
    print Dumper $info;

    foreach my $required (qw(title body primary_id)) {
        if (not defined $info->{$required}) {
            API::X->throw({
                message => "Missing required param : $required",
            });
        }
    }

    my $status;
    try {
        $status = $self->elastic->index(
            index => 'peptide_retention',
            type  => 'protein',
            id    => $info->{primary_id},
            body  => {
                title => $info->{title},
                body  => $info->{body},
                date  => $info->{date} // $self->_current_date,
            },
        );
    } catch {
        API::X->throw({
            message => "Failed to index document : $_",
        });
    };

    return $status;
}

sub _current_date {
    my $self = shift;

    my ($date) = split /T/, DateTime->now;

    return $date;
}

__PACKAGE__->meta->make_immutable;
