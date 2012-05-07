#! perl

use strict;
use warnings;

use lib 't/lib';

use File::Temp  qw/ tempdir tempfile /;
use HiD::Layout;
use HiD::Page;
use Template;

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

my $mdown_file = join '/' , $input_dir , 'markdown.mkdn';
open( my $MOUT , '>' , $mdown_file ) or die $!;
print $MOUT <<EOF;
---
title: this is a page with markdown
---
# this should be h1
EOF
close( $MOUT );

my( $layout_fh , $layout_file) = tempfile( SUFFIX => '.html' );
print $layout_fh <<EOF;
PAGE: [% content %]
EOF
close( $layout_fh );

my $dest_dir = tempdir();
diag "Output in $dest_dir";

run_tests(
  "basic page test" ,
  [
    'Test::HiD::Role::IsConverted' ,
    'Test::HiD::Role::IsPublished' ,
    'Test::HiD::Page' ,
  ] ,
  {
    converted_content => "this is some page content.\n",
    output_regexp     => qr/PAGE: this is some page content/ ,
    subject => HiD::Page->new({
      dest_dir       => $dest_dir,
      input_filename => $input_file ,
      layouts        => {
        default => HiD::Layout->new({
          filename  => $layout_file ,
          processor => Template->new( ABSOLUTE => 1 ) ,
        }) ,
      },
    }),
  },
);

run_tests(
  "markdown conversion test" ,
  [
    'Test::HiD::Role::IsConverted' ,
    'Test::HiD::Role::IsPublished' ,
    'Test::HiD::Page' ,
  ] ,
  {
    converted_content => "<h1>this should be h1</h1>\n",
    output_regexp     => qr|PAGE: <h1>this should be h1</h1>| ,
    subject => HiD::Page->new({
      dest_dir       => $dest_dir,
      input_filename => $mdown_file ,
      layouts        => {
        default => HiD::Layout->new({
          filename  => $layout_file ,
          processor => Template->new( ABSOLUTE => 1 ) ,
        }) ,
      },
    }),
  },
);


done_testing;
