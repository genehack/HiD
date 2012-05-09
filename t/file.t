#! perl

use strict;
use warnings;

use lib 't/lib';

use File::Temp  qw/ tempdir tempfile /;
use HiD::File;

use Test::More;
use Test::Routine::Util;

my( $fh , $input_file ) = tempfile( DIR => tempdir , SUFFIX => '.html' );
print $fh 'this is a regular file.';
close $fh;

run_tests(
  "basic file test" ,
  [ 'Test::HiD::Role::IsPublished' , 'Test::HiD::File' ] ,
  {
    expected_url => "$input_file" ,
    subject      => HiD::File->new({
      dest_dir       => tempdir() ,
      input_filename => $input_file ,
    }) ,
  },
);

my $dir = tempdir();
mkdir "$dir/nest";
my $nested_file = "$dir/nest/nested.html";
open( my $nested , '>' , $nested_file ) or die $!;
print $nested 'this is a nested file';
close( $nested );

run_tests(
  "nested file test" ,
  [ 'Test::HiD::Role::IsPublished' , 'Test::HiD::File' ] ,
  {
    expected_url => "$nested_file" ,
    subject      => HiD::File->new({
      dest_dir       => tempdir ,
      input_filename => $nested_file ,
    }) ,
  },
);


done_testing;
