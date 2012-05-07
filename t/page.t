#! perl

use strict;
use warnings;

use lib 't/lib';

use File::Temp  qw/ tempdir tempfile /;
use HiD::Layout;
use HiD::Page;

use Test::More;
use Test::Routine::Util;

my $input_dir  = tempdir();
my $input_file = join '/' , $input_dir , 'input.html';
open( my $OUT , '>' , $input_file ) or die $!;
print $OUT <<EOF;
---
title: this is a page
---
this is some page content.
EOF
close( $OUT );

my( $layout_fh , $layout_file) = tempfile( SUFFIX => '.html' );
print $layout_fh <<EOF;
[% content %]
EOF

run_tests(
  "basic page test" ,
  [
    'Test::HiD::Role::IsConverted' ,
    'Test::HiD::Role::IsPublished' ,
    'Test::HiD::Page' ,
  ] ,
  {
    subject => HiD::Page->new({
      dest_dir       => tempdir() ,
      input_filename => $input_file ,
      layouts        => {
        default => HiD::Layout->new({
          filename => $layout_file ,
        }) ,
      },
    }),
  },
);

done_testing;
