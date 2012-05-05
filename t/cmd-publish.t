#! perl

use strict;
use warnings;

use Test::File;
use Test::More;

use App::Cmd::Tester;
use HiD;

{
  chdir 't/test_site';

  open( my $fh , '>' , '_site/dummy_file' );

  my $result = test_app( 'HiD' => [ 'publish' ]);

  is   $result->stdout , '' , 'expected STDOUT';
  is   $result->stderr , '' , 'empty STDERR';
  is   $result->exit_code , 0 , 'success';

  file_not_exists_ok( '_site/dummy_file' );

  chdir '../..';
}

done_testing;
