use v5.14;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use GBV::OccurrencesServer;
use File::Temp qw(tempfile);

my (undef, $dbfile) = tempfile();
my $app = GBV::OccurrencesServer->new(dbfile => $dbfile);
my $test = Plack::Test->create($app);

my $res = $test->request(GET '/status');
is $res->code, 200;
note explain $res->content;

done_testing;
