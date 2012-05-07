package Test::HiD::Util;

use strict;
use warnings;

use File::Temp qw/ tempfile tempdir /;
use HiD;

sub bootstrap_hid {
  my $layout_dir  = tempdir();
  my $destination = tempdir();
  my $source_dir  = tempdir();

  bootstrap_layout( $layout_dir , 'default');

  return HiD->new({
    config => {
      layout_dir  => $layout_dir  ,
      destination => $destination ,
      source      => $source_dir  ,
    },
  })
}

sub bootstrap_layout {
  my( $dir , $name ) = @_;

  open( my $fh , '>' , "$dir/$name.html" ) or die $!;
  print $fh "[% content %]\n";
  close( $fh );
}

sub bootstrap_page {
  my( $dir , $name , $hid ) = @_;

  open( my $fh , '>' , "$dir/$name" ) or die $!;
  print $fh "---\nlayout: default\n---\nPAGE\n";

  return HiD::Page->new({
    filename => "$dir/$name",
    hid      => $hid ,
  });
}

1;
