#! perl

use strict;
use warnings;

use Test::File;
use Test::More;

use App::Cmd::Tester;
use File::Temp          qw/ tempdir /;
use HiD::App;
use YAML::XS            qw/ LoadFile /;

{
  my $dir = tempdir();
  chdir $dir or BAIL_OUT( "Couldn't get into tempdir" );

  my $result = test_app( 'HiD::App' => [ 'init' ]);

  like $result->stdout , qr/Enjoy/ , 'expected STDOUT';
  is   $result->stderr , '' , 'empty STDERR';
  is   $result->exit_code , 0 , 'success';

  file_exists_ok( "_config.yml" , 'See _config.yml' );

  foreach ( qw/ includes layouts site / ) {
    dir_exists_ok( "_$_" , "See _$_");
  }
}
{
  my $dir = tempdir();
  chdir $dir or BAIL_OUT( "Couldn't get into tempdir" );

  my $result = test_app( 'HiD::App' => [ 'init' , '--title' , 'My Site' ]);

  like $result->stdout , qr/Enjoy/ , 'expected STDOUT';
  is   $result->stderr , '' , 'empty STDERR';
  is   $result->exit_code , 0 , 'success';

  file_exists_ok( "_config.yml" , 'See _config.yml' );

  my $config = LoadFile( '_config.yml' );

  is( $config->{title} , 'My Site' , 'config built correctly' );
}


{
  my $dir = tempdir();
  chdir $dir or BAIL_OUT( "Couldn't get into tempdir" );

  my $result = test_app( 'HiD::App' => [ 'init' , '--blog' ]);

  like $result->stdout , qr/Enjoy/ , 'expected STDOUT';
  is   $result->stderr , '' , 'empty STDERR';
  is   $result->exit_code , 0 , 'success';

  file_exists_ok( "_config.yml" , 'See _config.yml' );

  foreach ( qw/ includes layouts posts site / ) {
    dir_exists_ok( "_$_" , "See _$_");
  }

  file_exists_ok( "_layouts/post.html" , 'See _layouts/post.html' );

}

TODO:
{
  local $TODO = 'add github support';

  my $dir = tempdir();
  chdir $dir or BAIL_OUT( "Couldn't get into tempdir" );

  my $result = test_app( 'HiD::App' => [ 'init' , '--github' ]);
  is $result->exit_code , 0 , 'success';
}

done_testing;
