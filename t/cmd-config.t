#! perl

use strict;
use warnings;

use lib 't/lib';

use Test::More;
use Test::HiD::Util qw/ write_bad_config write_config /;

use Path::Tiny;

use App::Cmd::Tester;
use HiD::App;

my $test_dir = Path::Tiny->tempdir();
chdir $test_dir or BAIL_OUT "Couldn't change to test dir";

{
  # --help prints usage
  my $result = test_app( 'HiD::App' => [ 'config' , '--help' ]);

  like $result->stdout    , qr/^(\S+) config/ , 'expected STDOUT';
  is   $result->stderr    , ''                , 'empty STDERR';
  is   $result->exit_code , 0                 , 'success';
}
{
  # fire warning with no _config.yml
  my $result = test_app( 'HiD::App' => [ 'config' ]);

  like $result->stdout    , qr/destination.*?"/              , 'expected STDOUT';
  like $result->stderr    , qr/Could not read configuration/ , 'warning on STDERR';
  is   $result->exit_code , 0                                , 'success';
}

write_config({});

{
  # and now we don't get the warning
  my $result = test_app( 'HiD::App' => [ 'config' ]);

  like $result->stdout    , qr/destination.*?"/ , 'expected STDOUT';
  is   $result->stderr    , ''                  , 'empty STDERR';
  is   $result->exit_code , 0                   , 'success';
}
{
  # dump a subsection of the config
  my $result = test_app( 'HiD::App' => [ 'config' , 'config' ]);

  like $result->stdout    , qr/destination.*?"/ , 'expected STDOUT';
  is   $result->stderr    , ''                  , 'empty STDERR';
  is   $result->exit_code , 0                   , 'success';
}

write_bad_config('BUSTED');

{
  # and now we get the warning again.
  my $result = test_app( 'HiD::App' => [ 'config' ]);

  like $result->stdout    , qr/destination.*?"/              , 'expected STDOUT';
  like $result->stderr    , qr/Could not read configuration/ , 'warning on STDERR';
  is   $result->exit_code , 0                                , 'success';
}

chdir('/');
done_testing();
