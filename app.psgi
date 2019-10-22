use lib './lib';
use GBV::OccurrencesServer;

my $app = GBV::OccurrencesServer->new(dbfile => "db.sqlite");

$app->to_app;
