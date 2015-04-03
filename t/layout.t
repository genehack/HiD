#! perl

use strict;
use warnings;
use feature 'state';

use lib 't/lib';

use Test::More;
use Test::Routine::Util;
use Test::HiD::Util      qw/ write_fixture_file /;

use Path::Tiny;
use Template;

use HiD::Layout;

my $template = Template->new();

my $fixture_dir = Path::Tiny->tempdir();

my $layout_file = $fixture_dir->child('default.html')->stringify();
write_fixture_file( $layout_file => '[% content %]' );

run_tests(
  "basic layout test" ,
  [ 'Test::HiD::Layout' ] ,
  {
    expected_output_regex => qr/test content/,
    subject => HiD::Layout->new({
      filename  => $layout_file ,
      processor => $template ,
    }) ,
    test_content => 'test content' ,
  },
);

my $outer_file = $fixture_dir->child('outer.html')->stringify();
write_fixture_file( $outer_file => 'OUTER: [% content %]' );
my $outer   = HiD::Layout->new({
  filename  => $outer_file ,
  processor => $template ,
});

my $inner_file = $fixture_dir->child('inner.html')->stringify();
write_fixture_file( $inner_file => << 'EOL' );
---
layout: outer
---
INNER: [% content %]
EOL
my $inner = HiD::Layout->new({
  filename  => $inner_file ,
  processor => $template ,
});
$inner->set_layout( $outer );

run_tests(
  "recursive layout test" ,
  [ 'Test::HiD::Layout' ] ,
  {
    expected_output_regex => qr/OUTER.*INNER.*test content/m ,
    subject               => $inner,
    test_content          => 'test content'
  }
);

run_tests(
  "render without write" ,
  [ 'Test::HiD::Layout' ] ,
  {
    expected_output_regex => qr/EMBED: embed test content/,
    test_content          => 'embed test content' ,
    subject               => HiD::Layout->new({
      name      => 'embed' ,
      content   => 'EMBED: [% content %]' ,
      processor => $template ,
    }),
  },
);

run_tests(
  "layout metadata folded into page" ,
  [ 'Test::HiD::Layout' ] ,
  {
    expected_output_regex => qr/yes, it worked it did/,
    test_content          => 'it did',
    subject               => HiD::Layout->new({
      name      => 'embed' ,
      content   => 'yes, it [% page.metatest %] [% content %]',
      metadata  => { metatest => 'worked' } ,
      processor => $template ,
    }),
  },
);

done_testing();
