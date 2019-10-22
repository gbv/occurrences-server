use v5.14;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use GBV::OccurrencesServer;
use File::Temp qw(tempfile);

my (undef, $dbfile) = tempfile();
my $app = GBV::OccurrencesServer->new(dbfile => $dbfile);
my $test = Plack::Test->create($app);

$app->insert_voc({ uri => 'http://example.org/a', notation => ['a'] });
$app->insert_voc({ uri => 'http://example.org/b', notation => ['b'] });

my $res = $test->request(GET '/voc');
is $res->code, 200;
note explain $res->content;

done_testing;
