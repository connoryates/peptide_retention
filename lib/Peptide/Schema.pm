package Peptide::Schema;
use Moose;
with 'Peptide::Schema::Role::_scaffold';

use Peptide::Config;

our %INSTANCES;

# delegate txn_* methods to the DBIx::Class object itself
has '+dbic' => (handles => [qw(txn_do txn_scope_guard txn_begin txn_commit txn_rollback)]);

around 'new' => sub {
    my $self = shift;
    my $orig = shift;

    if (not defined $INSTANCES{$self}) {
        $INSTANCES{$self} = $self->$orig(@_);
    }

    return $INSTANCES{$self};
};

sub connect_args {
     my $pg = $self->config->{database}->{pg};
     return ($pg->{dsn}, $pg->{user}, $pg->{password});
}

sub dbh {
    my $self = shift;
    return $INSTANCES{$self}->dbh || $self->dbic->storage->dbh;
}

__PACKAGE__->meta->make_immutable;
