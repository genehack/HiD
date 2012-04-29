#! perl

use strict;
use warnings;

use Test::More;

use App::Cmd::Tester;
use Hyde;

{
  my $result = test_app( 'Hyde' => [ 'publish' ]);

  like $result->stdout , qr/^publish/ , 'expected STDOUT';
  is   $result->stderr , '' , 'empty STDERR';
  is   $result->exit_code , 0 , 'success';
}

done_testing;
