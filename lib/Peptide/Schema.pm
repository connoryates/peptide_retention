package Peptide::Schema;
use Moose;
with 'Peptide::Schema::_scaffold';

use Peptide::Config;
use Try::Tiny;
use API::X;

our %INSTANCES;

# delegate txn_* methods to the DBIx::Class object itself
has '+dbic' => (handles => [qw(txn_do txn_scope_guard txn_begin txn_commit txn_rollback)]);

has 'config' => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    builder => '_build_config',
);

sub _build_config {
    return Peptide::Config->new->config;
}

around BUILDARGS => sub {
    my $orig = shift;
    my $self = shift;

    if (not defined $INSTANCES{$self}) {
        $INSTANCES{$self} = $self->$orig(@_);
    }

    return $INSTANCES{$self};
};

sub connect_args {
     my $self = shift;

     my $pg;
     try {
         $pg = $self->config->{database}->{pg};
     } catch {
         API::X->throw({
             message => "Cannot find database config! : $_",
         });
     };

     return ($pg->{dsn}, $pg->{user}, $pg->{password});
}

sub dbh {
    my $self = shift;
    return $self->dbic->storage->dbh;
    # return $INSTANCES{$self}->dbh || $self->dbic->storage->dbh;
}

__PACKAGE__->meta->make_immutable;

=pod

=head1 our %INSTANCES

Hold instances of this PACKAGE in memory and return the blessed instance instead of
creating a new PACKAGE. Minimizes database connections

=head2 around BUILDARGS

Moose hook to check for and set blessed packages in %INSTANCES. 

=head3 connect_args

Return the DBI connection arguments. Mandatory for Mesoderm.

=head4 dbh

Return the stored dbh handle

=cut
