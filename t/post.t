#! perl

use strict;
use warnings;

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
author: x
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
author: x
category: markdown
---
# this should be h1
EOF
    ),
  },
  "textile conversion test" => {
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_categories      => [] ,
    expected_date            => '2011-11-11',
    expected_title           => 'textile post',
    expected_url             => '/2011/11/11/textile.html',
    output_regexp            => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    subject                  => make_post(
      file    => '2011-11-11-textile.textile',
      layouts => $layouts ,
      content => <<EOF,
---
title: textile post
author: x
---
h1. this should be h1
EOF
    ),
  },
  "permalink = pretty" => {
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_categories      => [ qw/ foo bar / ] ,
    expected_date            => '2010-10-10' ,
    expected_title           => 'this is a markdown post',
    expected_url             => '/foo/bar/2010/10/10/markdown2/',
    output_regexp            => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    subject                  => make_post(
      file    => '2010-10-10-markdown2.markdown',
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a markdown post
author: x
categories: foo bar
permalink: pretty
---
# this should be h1
EOF
    ),
  },
  "permalink = string" => {
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_categories      => [ ] ,
    expected_date            => '2010-10-10' ,
    expected_title           => 'this is a markdown post',
    expected_url             => 'permalink/',
    output_regexp            => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    subject                  => make_post(
      file    => '2010-10-10-permalink-string.markdown',
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a markdown post
author: x
permalink: permalink/
---
# this should be h1
EOF
    ),
  },
  "permalink = format string" => {
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_categories      => [ ] ,
    expected_date            => '2010-10-10' ,
    expected_title           => 'this is a markdown post',
    expected_url             => '2010-10-10-permalink',
    output_regexp            => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    subject                  => make_post(
      file    => '2010-10-10-permalink-format-string.markdown',
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a markdown post
author: x
permalink: '%{year}s-%{month}s-%{day}s-permalink'
---
# this should be h1
EOF
    ),
  },
  "excerpt" => {
    converted_content_regexp => qr|<h1>this should be h1</h1>\s*<p>content</p>|,
    converted_excerpt_regexp => qr|<h1>this should be h1</h1>.+read more|s,
    expected_categories      => [ ] ,
    expected_date            => '2010-10-10' ,
    expected_title           => 'this is a excerpt test',
    expected_url             => '2010-10-10-excerpt',
    output_regexp            => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    subject                  => make_post(
      file    => '2010-10-10-excerpt.markdown',
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a excerpt test
author: x
permalink: '%{year}s-%{month}s-%{day}s-excerpt'
---
# this should be h1


content
EOF
    ),
  },
  "metadata:date" => {
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_categories      => [ ] ,
    expected_date            => '2012-12-12 01:02:03' ,
    expected_title           => 'this is a markdown post',
    expected_url             => '/2012/12/12/metadata-date/',
    output_regexp            => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    subject                  => make_post(
      file    => '2010-10-10-metadata-date.markdown',
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a markdown post
author: x
permalink: pretty
date: 2012-12-12 01:02:03
---
# this should be h1
EOF
    ),
  },
  "category post test" => {
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_categories      => [ qw/ foo bar / ] ,
    expected_date            => '2010-10-10' ,
    expected_title           => 'this is a markdown post',
    expected_url             => '/foo/bar/2010/10/10/markdown.html',
    output_regexp            => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    subject                  => make_post(
      file    => 'foo/bar/_posts/2010-10-10-markdown.markdown',
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a markdown post
author: x
category: baz
---
# this should be h1
EOF
    ),
  },
  "yaml category post test" => {
    converted_content_regexp => qr|<h1>this should be h1</h1>|,
    expected_categories      => [ qw/ bar foo / ] ,
    expected_date            => '2010-10-10' ,
    expected_title           => 'this is a markdown post',
    expected_url             => '/bar/foo/2010/10/10/markdown.html',
    output_regexp            => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    rendered_content_regexp  => qr|PAGE: POST: <h1>this should be h1</h1>| ,
    subject                  => make_post(
      file    => '2010-10-10-markdown.markdown',
      layouts => $layouts ,
      content => <<EOF,
---
title: this is a markdown post
author: x
categories:
 - bar
 - foo
---
# this should be h1
EOF
    ),
  },
);

my $test_files = [
  'Test::HiD::Role::IsConverted' ,
  'Test::HiD::Role::IsPublished' ,
  'Test::HiD::Role::IsPost' ,
  'Test::HiD::Post' ,
];

# and run tests
map { run_tests( $_ , $test_files , $tests{$_} ) } keys %tests;

done_testing;
