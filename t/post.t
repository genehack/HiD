#! perl

use strict;
use warnings;
use 5.010;

use lib 't/lib';

use File::Temp  qw/ tempdir tempfile /;
use HiD::Layout;
use HiD::Post;
use Template;

use Test::HiD::Util      qw/ make_layout make_post /;
use Test::More;
use Test::Routine::Util;

# make layouts
my $default = make_layout( content => 'PAGE: [% content %]' );
my $layouts = {
  default => $default ,
  post    => make_layout(
    layout  => $default ,
    content => <<EOF ,
---
layout: default
---
POST: [% content %]
EOF
  ),
};

my %tests = (
  "basic post test" =>   {
    converted_content_regexp => qr/this is some post content./,
    expected_categories      => [],
    expected_date            => '2010-01-01',
    expected_title           => 'this is a post' ,
    expected_url             => '/2010/01/01/test.html',
    output_regexp            => qr/PAGE: POST: this is some post content/ ,
    rendered_content_regexp  => qr/PAGE: POST: this is some post content/ ,
    subject                  => make_post(
      file    => '2010-01-01-test.html' ,
      layouts => $layouts ,
      content => <<EOF,
---
layout: post
title: this is a post
---
this is some post content.
EOF
    ),
  },
  "markdown post test" => {
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_categories      => [ qw/ markdown / ] ,
    expected_date            => '2010-10-10' ,
    expected_title           => 'this is a markdown post',
    expected_url             => '/markdown/2010/10/10/markdown.html',
    output_regexp            => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    subject                  => make_post(
      file    => '2010-10-10-markdown.markdown',
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a markdown post
category: markdown
---
# this should be h1
EOF
    ),
  },
  # textile
  # permalink: pretty
  # permalink: string
  # permalink: format string
);

my $test_files = [
  'Test::HiD::Role::IsConverted' ,
  'Test::HiD::Role::IsPublished' ,
  'Test::HiD::Role::IsPost' ,
  'Test::HiD::Post' ,
];

# and run tests
map { run_tests( $_ , $test_files , $tests{$_} ) } keys %tests;

# run_tests(
#   "textile conversion test" ,
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
