use strict;

use lib 't/lib';

#this is just part of the plack distribution, not only in the test suite regular test so I used it
use Plack::Test;
use Test::More;
use HiD::Server;
use Test::HiD::Util        qw/ write_fixture_file /;
use HTTP::Request::Common;
use Path::Tiny;
use FindBin qw($Bin);

#tests for the configurable error pages

#test the default Plack::App::File behavior
my $app_secure = HiD::Server->new(root => $Bin);
test_psgi $app_secure, sub {
  my $cb = shift;

  my $res = $cb->(GET "/hid-server.t");
  is $res->code, 200;
  like $res->content, qr/We will find for this literal string/;

  my $res = $cb->(GET "/no_hid-server");
  is $res->code, 404;
  like $res->content, qr/not found/;
};

#test a custom error page
$app_secure = HiD::Server->new(
  root => $Bin,
  error_pages => { 404 => "hid-server.t"}
);

test_psgi $app_secure, sub {
  my $cb = shift;
  my $res = $cb->(GET "/no_hid-server");
  is $res->code, 404;
  like $res->content, qr/We will find for this lteral string/;
};


#test a custom error page that doesn't exist
$app_secure = HiD::Server->new(
  root => $Bin,
  error_pages => { 404 => "not exists.t"}
);
test_psgi $app_secure, sub {
  my $cb = shift;
  my $res = $cb->(GET "/no_hid-server");
  is $res->code, 404;
  like $res->content, qr/not found/;
};


#test default error page "404.html"  with no custom error page configured
my $test_dir  = Path::Tiny->tempdir();
mkdir "${test_dir}/_site";
write_fixture_file( "${test_dir}/_site/404.html", q|And sky not Bruce this| );

$app_secure = HiD::Server->new(
    root => "$test_dir/_site",
);
test_psgi $app_secure, sub {
    my $cb = shift;
    my $res = $cb->(GET "/no_hid-server");
    is $res->code, 404;
    like $res->content, qr/And sky not Bruce this/;
};

#test the default error page and custom error page that doesn't exist
$app_secure = HiD::Server->new(
    root => "$test_dir/_site",
    error_pages => { 404 => "no-page.html"}
);
test_psgi $app_secure, sub {
    my $cb = shift;
    my $res = $cb->(GET "/no_hid-server");
    is $res->code, 404;
    like $res->content, qr/And sky not Bruce this/;
};

done_testing;
