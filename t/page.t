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
my $input_url  = "/$input_file";
open( my $OUT , '>' , $input_file ) or die $!;
print $OUT <<EOF;
---
title: this is a page
---
this is some page content.
EOF
close( $OUT );

my $mdown_file = join '/' , $input_dir , 'markdown.mkdn';
my $mdown_url  = "/$input_dir/markdown.html";
open( my $MOUT , '>' , $mdown_file ) or die $!;
print $MOUT <<EOF;
---
title: this is a page with markdown
---
# this should be h1
EOF
close( $MOUT );

my $textile_file = join '/' , $input_dir , 'textile.textile';
my $textile_url  = "/$input_dir/textile.html";
open( my $TOUT , '>' , $textile_file ) or die $!;
print $TOUT <<EOF;
---
title: this is a page with textile
---
h1. this should be h1

EOF
close( $TOUT );

my $pretty_file = join '/' , $input_dir , 'pretty.html';
my $pretty_url  = "/$input_dir/pretty/";
open( my $POUT , '>' , $pretty_file ) or die $!;
print $POUT <<EOF;
---
title: this is a pretty page
permalink: pretty
---
this is some pretty page content.
EOF
close( $POUT );

my $perma_file = join '/' , $input_dir , 'perma.html';
my $perma_url  = "/permalink";
open( my $PLOUT , '>' , $perma_file ) or die $!;
print $PLOUT <<EOF;
---
title: this is a permalink page
permalink: permalink
---
this is some page content.
EOF
close( $PLOUT );


my( $layout_fh , $layout_file) = tempfile( SUFFIX => '.html' );
print $layout_fh <<EOF;
PAGE: [% content %]
EOF
close( $layout_fh );

my $dest_dir = tempdir();

run_tests(
  "basic page test" ,
  [
    'Test::HiD::Role::IsConverted' ,
    'Test::HiD::Role::IsPublished' ,
    'Test::HiD::Page' ,
  ] ,
  {
    converted_content_regexp => qr/this is some page content./,
    expected_url             => $input_url ,
    output_regexp            => qr/PAGE: this is some page content/ ,
    rendered_content_regexp  => qr/PAGE: this is some page content/ ,
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
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_url             => $mdown_url ,
    output_regexp            => qr|PAGE: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: <h1>this should be h1</h1>| ,
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

run_tests(
  "textile conversion test" ,
  [
    'Test::HiD::Role::IsConverted' ,
    'Test::HiD::Role::IsPublished' ,
    'Test::HiD::Page' ,
  ] ,
  {
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_url             => $textile_url ,
    output_regexp            => qr|PAGE: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: <h1>this should be h1</h1>| ,
    subject => HiD::Page->new({
      dest_dir       => $dest_dir,
      input_filename => $textile_file ,
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
  "permalink = pretty" ,
  [
    'Test::HiD::Role::IsConverted' ,
    'Test::HiD::Role::IsPublished' ,
    'Test::HiD::Page' ,
  ] ,
  {
    converted_content_regexp => qr/this is some pretty page content./,
    expected_url             => $pretty_url ,
    output_regexp            => qr/PAGE: this is some pretty page content/ ,
    rendered_content_regexp  => qr/PAGE: this is some pretty page content/ ,
    subject => HiD::Page->new({
      dest_dir       => $dest_dir,
      input_filename => $pretty_file ,
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
  "permalink = constant" ,
  [
    'Test::HiD::Role::IsConverted' ,
    'Test::HiD::Role::IsPublished' ,
    'Test::HiD::Page' ,
  ] ,
  {
    converted_content_regexp => qr/this is some page content./,
    expected_url             => $perma_url,
    output_regexp            => qr/PAGE: this is some page content/ ,
    rendered_content_regexp  => qr/PAGE: this is some page content/ ,
    subject => HiD::Page->new({
      dest_dir       => $dest_dir,
      input_filename => $perma_file ,
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
