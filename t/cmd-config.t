#! perl

use strict;
use warnings;

use Test::More;

use autodie;
use Cwd;
use File::Temp  qw/ tempfile tempdir /;
use YAML::XS    qw/ DumpFile /;

use App::Cmd::Tester;
use HiD::App;

my $start_dir = cwd;
my $test_dir  = tempdir( CLEANUP => 1 );

chdir $test_dir or BAIL_OUT "Couldn't change to test dir";

{
  # --help prints usage
  my $result = test_app( 'HiD::App' => [ 'config' , '--help' ]);

  like $result->stdout    , qr/^(\S+) config/ , 'expected STDOUT';
  is   $result->stderr    , ''              , 'empty STDERR';
  is   $result->exit_code , 0               , 'success';
}
{
  # fire warning with no _config.yml
  my $result = test_app( 'HiD::App' => [ 'config' ]);

  like $result->stdout    , qr/destination.*"_site"/ , 'expected STDOUT';
  like $result->stderr    , qr/WARNING: Could not read configuration/ , 'warning on STDERR';
  is   $result->exit_code , 0           , 'success';
}

# write out empty config file
DumpFile( '_config.yml' , {} );

{
  # and now we don't get the warning
  my $result = test_app( 'HiD::App' => [ 'config' ]);

  like $result->stdout    , qr/destination.*"_site"/ , 'expected STDOUT';
  is   $result->stderr    , ''          , 'empty STDERR';
  is   $result->exit_code , 0           , 'success';
}
{
  # dump a subsection of the config
  my $result = test_app( 'HiD::App' => [ 'config' , 'config' ]);

  like $result->stdout    , qr/destination.*"_site"/ , 'expected STDOUT';
  is   $result->stderr    , ''          , 'empty STDERR';
  is   $result->exit_code , 0           , 'success';
}

# write out a bad config file
open( my $fh , '>' , '_config.yml' );
print $fh 'BUSTED!';
close( $fh );

{
  # and now we get the warning again.
  my $result = test_app( 'HiD::App' => [ 'config' ]);

  like $result->stdout    , qr/destination.*"_site"/ , 'expected STDOUT';
  like $result->stderr    , qr/WARNING: Could not read configuration/ , 'warning on STDERR';
  is   $result->exit_code , 0           , 'success';
}

# there's no place like home.
unlink '_config.yml';
chdir $start_dir;
done_testing;
