#! perl

use strict;
use warnings;
use feature 'state';

use lib 't/lib';

use File::Temp  qw/ tempdir tempfile /;
use HiD::Layout;
use Template;

use Test::More;
use Test::Routine::Util;

my $template = Template->new();

my $layout_file = _write_layout( default => '[% content %]');

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

my $outer_file = _write_layout( outer => 'OUTER: [% content %]' );
my $inner_file = _write_layout( inner => <<EOL );
---
layout: outer
---
INNER: [% content %]
EOL

my $subject = HiD::Layout->new({
  filename  => $inner_file ,
  processor => $template ,
});
my $outer   = HiD::Layout->new({
  filename  => $outer_file ,
  processor => $template ,
});
$subject->set_layout( $outer );

run_tests(
  "recursive layout test" ,
  [ 'Test::HiD::Layout' ] ,
  {
    expected_output_regex => qr/OUTER.*INNER.*test content/m ,
    subject               => $subject,
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

done_testing;

sub _write_layout {
  my( $name , $content ) = @_;

  state $layout_dir = tempdir();

  my $filename = "$layout_dir/$name.html";

  open( my $fh , '>' , $filename ) or die $!;
  print $fh $content;
  close( $fh );

  return $filename;
}
