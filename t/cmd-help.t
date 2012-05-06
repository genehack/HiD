#! perl

use strict;
use warnings;

use Test::More;

use App::Cmd::Tester;
use HiD::App;

{
  my $result = test_app( 'HiD::App' => [ 'help' ]);

  like $result->stdout , qr/^Available commands:/ , 'expected STDOUT';
  is   $result->stderr , '' , 'empty STDERR';
  is   $result->exit_code , 0 , 'success';
}

done_testing;
