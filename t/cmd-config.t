#! perl

use strict;
use warnings;

use Test::More;

use App::Cmd::Tester;
use HiD;

{
  my $result = test_app( 'HiD' => [ 'config' ]);

  like $result->stdout    , qr/\\ \{\}/ , 'expected STDOUT';
  is   $result->stderr    , ''          , 'empty STDERR';
  is   $result->exit_code , 0           , 'success';
}
{
  my $result = test_app( 'HiD' => [ 'config' , 'config' ]);

  like $result->stdout    , qr/\\ \{\}/ , 'expected STDOUT';
  is   $result->stderr    , ''          , 'empty STDERR';
  is   $result->exit_code , 0           , 'success';
}
{
  my $result = test_app( 'HiD' => [ 'config' , '--help' ]);

  like $result->stdout    , qr/^(\S+) config/ , 'expected STDOUT';
  is   $result->stderr    , ''              , 'empty STDERR';
  is   $result->exit_code , 0               , 'success';
}

done_testing;
