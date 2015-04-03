#! perl

use strict;
use warnings;

use lib 't/lib';

use Test::More;
use Test::Routine::Util;
use Test::HiD::Util      qw/ make_layout make_page /;

use Path::Tiny;
use Template;

use HiD::Layout;
use HiD::Page;

my $tmp = Path::Tiny->tempdir->stringify();

my $layouts = {
  default => make_layout( content => 'PAGE: [% content %]' ),
};

my %tests = (
  "basic page test" => {
    converted_content_regexp => qr/this is some page content./,
    expected_basename        => 'input' ,
    expected_dir             => $tmp ,
    expected_suffix          => 'html' ,
    expected_url             => '/input.html' ,
    output_regexp            => qr/PAGE: this is some page content/ ,
    rendered_content_regexp  => qr/PAGE: this is some page content/ ,
    subject                  => make_page(
      dir     => $tmp ,
      file    => 'input.html',
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a page
---
this is some page content.
EOF
    ),
  },
  "markdown conversion test" => {
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_basename        => 'markdown' ,
    expected_dir             => $tmp ,
    expected_suffix          => 'mkdn' ,
    expected_url             => '/markdown.html',
    output_regexp            => qr|PAGE: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: <h1>this should be h1</h1>| ,
    subject                  => make_page(
      dir     => $tmp ,
      file    => 'markdown.mkdn' ,
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a page with markdown
---
# this should be h1
EOF
    ),
  },
  "textile conversion test" => {
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_basename        => 'textile' ,
    expected_dir             => $tmp ,
    expected_suffix          => 'textile' ,
    expected_url             => '/textile.html' ,
    output_regexp            => qr|PAGE: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: <h1>this should be h1</h1>| ,
    subject                  => make_page(
      dir     => $tmp ,
      file    => 'textile.textile',
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a page with textile
---
h1. this should be h1
EOF
    ),
  },
  "permalink = pretty" => {
    converted_content_regexp => qr/this is some pretty page content./,
    expected_basename        => 'pretty' ,
    expected_dir             => $tmp ,
    expected_suffix          => 'html' ,
    expected_url             => '/pretty/' ,
    output_regexp            => qr/PAGE: this is some pretty page content/ ,
    rendered_content_regexp  => qr/PAGE: this is some pretty page content/ ,
    subject                  => make_page(
      dir     => $tmp ,
      file    => 'pretty.html',
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a pretty page
permalink: pretty
---
this is some pretty page content.
EOF
    ),
  },
  "permalink = constant" => {
    converted_content_regexp => qr/this is some page content./,
    expected_basename        => 'perma' ,
    expected_dir             => $tmp ,
    expected_suffix          => 'html' ,
    expected_url             => '/permalink',
    output_regexp            => qr/PAGE: this is some page content/ ,
    rendered_content_regexp  => qr/PAGE: this is some page content/ ,
    subject                  => make_page(
      dir     => $tmp ,
      file    => 'perma.html' ,
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a permalink page
permalink: permalink
---
this is some page content.
EOF
    ),
  },
);

my $test_files = [
  'Test::HiD::Role::IsConverted' ,
  'Test::HiD::Role::IsPublished' ,
  'Test::HiD::Page' ,
];

# and run tests
map { run_tests( $_ , $test_files , $tests{$_} ) } keys %tests;

done_testing();
