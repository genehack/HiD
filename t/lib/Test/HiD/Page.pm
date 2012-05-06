package Test::HiD::Page;
use Moose;
with 'Test::HiD::Role::IsPublishable';

use namespace::autoclean;

use File::Temp qw/ tempfile tempdir /;
use HiD;
use HiD::Page;

sub build_object_to_test {
  my( $fh , $name ) = tempfile( SUFFIX => '.html' );
  print $fh "---\nlayout: default\n---\nPAGE\n";

  my $site_dir   = tempdir();
  my $layout_dir = tempdir();

  {
    open( my $fh , '>' , "$layout_dir/default.html" ) or die $!;
    print $fh "[% content %]\n";
    close( $fh );
  }

  return HiD::Page->new({
    filename => $name,
    hid      => HiD->new({
      layout_dir => $layout_dir,
      site_dir   => $site_dir,
    }),
  });
}

1;
