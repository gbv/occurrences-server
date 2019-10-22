package GBV::OccurrencesServer;
use v5.14;

use DBI;
use Plack::Builder;
use JSON;

use parent 'Plack::Component';
use Plack::Util::Accessor qw(db dbfile);

sub new {
    my $self = Plack::Component::new(@_);
    $self->init_db;
    $self->init_app;
    $self;
}

sub init_db {
    my $self = shift;

    $self->db( DBI->connect( "dbi:SQLite:dbname=" . $self->dbfile, "", "" ) );
    $self->db->do("PRAGMA foreign_keys = ON");

    $self->db->do(
        q{
        CREATE TABLE vocabularies (
            voc      TINYINT PRIMARY KEY,
            uri      VARCHAR NOT NULL UNIQUE,
            notation VARCHAR NOT NULL UNIQUE,
            jskos    VARCHAR NOT NULL
        )
    }
    );

    $self->db->do(
        q{
        CREATE TABLE occurrences (
            ppn      INTEGER PRIMARY KEY,
            voc      TINYINT NOT NULL,
            notation VARCHAR NOT NULL,
            source   VARCHAR,
            FOREIGN KEY (voc) REFERENCES vocabularies(voc)
        )
    }
    );

    $self->{statement} = {};
    my %statements = (
        insert_voc =>
          "INSERT INTO vocabularies(uri,notation,jskos) VALUES (?,?,?)",
        insert_occ =>
          "INSERT INTO occurrences(ppn, voc, notation, source) VALUES (?,?,?,?)"
    );

    foreach ( keys %statements ) {
        $self->{statement}{$_} = $self->db->prepare( $statements{$_} );
    }

}

sub init_app {
    my $self = shift;
    $self->{app} = builder {
        enable 'CrossOrigin', origins => '*';
        enable 'Headers',
          set => [ 'Content-Type' => 'application/json; charset=utf-8' ];
        mount '/voc'         => sub { $self->voc(@_) };
        mount '/occurrences' => sub { $self->occurrences(@_) };
        mount '/status'      => sub { $self->status };
        mount '/'            => sub { [ 307, [ Location => 'status' ], [] ] };
    };
}

sub call {
    my ( $self, $env ) = @_;
    return $self->{app}($env);
}

sub status {
    my $self   = shift;
    my $status = {
        schemes     => JSON::true,
        occurrences => JSON::true
    };
    return [ 200, [], [ encode_json($status) ] ];
}

sub voc {
    my ( $self, $env ) = @_;

    # TODO: select by uri and/or notation
    my $json = $self->db->selectall_arrayref('SELECT jskos FROM vocabularies');
    return [ 200, [], [ encode_json($json) ] ];
}

sub occurrences {
    my ( $self, $env ) = @_;

    # TODO: select which occurrences to get
    my $json = [];

    return [ 200, [], [ encode_json($json) ] ];
}

# insert a vocabulary given as JSKOS Concept Scheme
sub insert_voc {
    my ( $self, $jskos ) = @_;

    $self->{statement}{insert_voc}
      ->execute( $jskos->{uri}, $jskos->{notation}[0], encode_json($jskos) );
}

# insert an occurrence given as JSKOS Occurrence
sub insert_occ {
    my ( $self, $jskos ) = @_;

    # TODO: get PPN via $jskos->{resource}{uri}

    # TODO: call insert_occ_row
}

sub insert_occ_row {
    my ( $self, $ppn, $voc, $notation, $source ) = @_;

    # TODO: convert PPN to integer

    $self->{statement}{insert_occurrence}
      ->execute( $ppn, $voc, $notation, $source );
}

1;
