#! perl

use strict;
use warnings;

use Test::More;

use App::Cmd::Tester;
use HiD;

{
  chdir 't/test_site';

  my $result = test_app( 'HiD' => [ 'publish' ]);

  is   $result->stdout , '' , 'expected STDOUT';
  is   $result->stderr , '' , 'empty STDERR';
  is   $result->exit_code , 0 , 'success';

  chdir '../..';
}

done_testing;
