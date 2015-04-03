#! perl

use strict;
use warnings;

use Test::More;
use Test::File;

use Path::Tiny;
use YAML::Tiny;

use App::Cmd::Tester;
use HiD::App;

{
  my $dir = Path::Tiny->tempdir();
  chdir $dir or BAIL_OUT( "Couldn't get into tempdir" );

  my $result = test_app( 'HiD::App' => [ 'init' ]);

  like $result->stdout    , qr/Enjoy/ , 'expected STDOUT';
  is   $result->stderr    , ''        , 'empty STDERR';
  is   $result->exit_code , 0         , 'success';

  file_exists_ok( "_config.yml" , 'See _config.yml' );

  foreach ( qw/ includes layouts site / ) {
    dir_exists_ok( "_$_" , "See _$_");
  }

  chdir('/');
}

{
  my $dir = Path::Tiny->tempdir();
  chdir $dir or BAIL_OUT( "Couldn't get into tempdir" );

  my $result = test_app( 'HiD::App' => [ 'init' , '--title' , 'My Site' ]);

  like $result->stdout    , qr/Enjoy/ , 'expected STDOUT';
  is   $result->stderr    , ''        , 'empty STDERR';
  is   $result->exit_code , 0         , 'success';

  file_exists_ok( "_config.yml" , 'See _config.yml' );

  my $config = YAML::Tiny->read( '_config.yml' );

  is( $config->[0]{title} , 'My Site' , 'config built correctly' );

  chdir('/');
}


{
  my $dir = Path::Tiny->tempdir();
  chdir $dir or BAIL_OUT( "Couldn't get into tempdir" );

  my $result = test_app( 'HiD::App' => [ 'init' , '--blog' ]);

  like $result->stdout    , qr/Enjoy/ , 'expected STDOUT';
  is   $result->stderr    , ''        , 'empty STDERR';
  is   $result->exit_code , 0         , 'success';

  file_exists_ok( "_config.yml" , 'See _config.yml' );

  foreach ( qw/ includes layouts posts site / ) {
    dir_exists_ok( "_$_" , "See _$_");
  }

  file_exists_ok( "_layouts/post.html" , 'See _layouts/post.html' );

  chdir('/');
}

done_testing();
