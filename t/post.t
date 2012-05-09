#! perl

use strict;
use warnings;

use lib 't/lib';

use File::Temp  qw/ tempdir tempfile /;
use HiD::Layout;
use HiD::Post;
use Template;

use Test::More;
use Test::Routine::Util;

my $input_dir  = tempdir();
my $input_post = join '/' , $input_dir , '2010-01-01-test.html';
my $input_url  = "/2010/01/01/test.html";
open( my $OUT , '>' , $input_post ) or die $!;
print $OUT <<EOF;
---
layout: post
title: this is a post
---
this is some post content.
EOF
close( $OUT );

# markdown
# textile
# permalink: pretty
# permalink: string
# permalink: format string

my $template = Template->new( ABSOLUTE => 1 );

my( $default_layout_fh , $default_layout_file) = tempfile( SUFFIX => '.html' );
print $default_layout_fh <<EOF;
PAGE: [% content %]
EOF
close( $default_layout_fh );
my $default_layout = HiD::Layout->new({
  filename  => $default_layout_file ,
  processor => $template ,
});

my( $post_layout_fh , $post_layout_file ) = tempfile( SUFFIX => '.html' );
print $post_layout_fh <<EOF;
---
layout: default
---
POST: [% content %]
EOF
close( $post_layout_fh );
my $post_layout = HiD::Layout->new({
  filename  => $post_layout_file ,
  processor => $template ,
  layout    => $default_layout,
});

my $dest_dir = tempdir();

run_tests(
  "basic post test" ,
  [
    'Test::HiD::Role::IsConverted' ,
    'Test::HiD::Role::IsPublished' ,
    'Test::HiD::Role::IsPost' ,
    'Test::HiD::Post' ,
  ] ,
  {
    converted_content_regexp => qr/this is some post content./,
    expected_date            => '2010-01-01',
    expected_title           => 'this is a post' ,
    expected_url             => $input_url ,
    output_regexp            => qr/PAGE: POST: this is some post content/ ,
    rendered_content_regexp  => qr/PAGE: POST: this is some post content/ ,
    subject => HiD::Post->new({
      dest_dir       => $dest_dir,
      input_filename => $input_post ,
      layouts        => {
        default => $default_layout ,
        post    => $post_layout ,
      },
    }),
  },
);

# run_tests(
#   "markdown conversion test" ,
#   [
#     'Test::HiD::Role::IsConverted' ,
#     'Test::HiD::Role::IsPublished' ,
#     'Test::HiD::Page' ,
#   ] ,
#   {
#     converted_content_regexp => qr|<h1>this should be h1</h1>|,
#     expected_url             => $mdown_url ,
#     output_regexp            => qr|PAGE: <h1>this should be h1</h1>| ,
#     rendered_content_regexp  => qr|PAGE: <h1>this should be h1</h1>| ,
#     subject => HiD::Page->new({
#       dest_dir       => $dest_dir,
#       input_filename => $mdown_file ,
#       layouts        => {
#         default => HiD::Layout->new({
#           filename  => $layout_file ,
#           processor => Template->new( ABSOLUTE => 1 ) ,
#         }) ,
#       },
#     }),
#   },
# );

# run_tests(
#   "textile conversion test" ,
#   [
#     'Test::HiD::Role::IsConverted' ,
#     'Test::HiD::Role::IsPublished' ,
#     'Test::HiD::Page' ,
#   ] ,
#   {
#     converted_content_regexp => qr|<h1>this should be h1</h1>|,
#     expected_url             => $textile_url ,
#     output_regexp            => qr|PAGE: <h1>this should be h1</h1>| ,
#     rendered_content_regexp  => qr|PAGE: <h1>this should be h1</h1>| ,
#     subject => HiD::Page->new({
#       dest_dir       => $dest_dir,
#       input_filename => $textile_file ,
#       layouts        => {
#         default => HiD::Layout->new({
#           filename  => $layout_file ,
#           processor => Template->new( ABSOLUTE => 1 ) ,
#         }) ,
#       },
#     }),
#   },
# );

# run_tests(
#   "permalink = pretty" ,
#   [
#     'Test::HiD::Role::IsConverted' ,
#     'Test::HiD::Role::IsPublished' ,
#     'Test::HiD::Page' ,
#   ] ,
#   {
#     converted_content_regexp => qr/this is some pretty page content./,
#     expected_url             => $pretty_url ,
#     output_regexp            => qr/PAGE: this is some pretty page content/ ,
#     rendered_content_regexp  => qr/PAGE: this is some pretty page content/ ,
#     subject => HiD::Page->new({
#       dest_dir       => $dest_dir,
#       input_filename => $pretty_file ,
#       layouts        => {
#         default => HiD::Layout->new({
#           filename  => $layout_file ,
#           processor => Template->new( ABSOLUTE => 1 ) ,
#         }) ,
#       },
#     }),
#   },
# );

# run_tests(
#   "permalink = constant" ,
#   [
#     'Test::HiD::Role::IsConverted' ,
#     'Test::HiD::Role::IsPublished' ,
#     'Test::HiD::Page' ,
#   ] ,
#   {
#     converted_content_regexp => qr/this is some page content./,
#     expected_url             => $perma_url,
#     output_regexp            => qr/PAGE: this is some page content/ ,
#     rendered_content_regexp  => qr/PAGE: this is some page content/ ,
#     subject => HiD::Page->new({
#       dest_dir       => $dest_dir,
#       input_filename => $perma_file ,
#       layouts        => {
#         default => HiD::Layout->new({
#           filename  => $layout_file ,
#           processor => Template->new( ABSOLUTE => 1 ) ,
#         }) ,
#       },
#     }),
#   },
# );

done_testing;
