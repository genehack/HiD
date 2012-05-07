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

run_tests(
  "basic file test" ,
  [ 'Test::HiD::Role::IsPublished' , 'Test::HiD::File' ] ,
  {
    subject => HiD::File->new({
      dest_dir       => tempdir() ,
      input_filename => $input_file ,
    }) ,
  },
);

done_testing;
