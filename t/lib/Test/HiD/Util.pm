use 5.014;
use warnings;

package Test::HiD::Util;

use File::Basename  qw/ fileparse /;
use File::Path      qw/ make_path /;
use File::Temp      qw/ tempfile tempdir /;
use HiD;
use HiD::Layout;
use HiD::Page;
use HiD::Post;
use Template;

use Exporter 'import';
our @EXPORT_OK = qw/ make_layout make_page make_post /;

sub make_layout {
  my( %arg ) = @_;

  state $template = Template->new( ABSOLUTE => 1 );

  my( $fh , $file) = tempfile( SUFFIX => '.html' );
  print $fh $arg{content};
  close( $fh );

  my $layout_args = {
    filename  => $file ,
    processor => $template ,
  };
  $layout_args->{layout} = $arg{layout} if $arg{layout};

  return HiD::Layout->new( $layout_args );
}

sub make_page {
  my( %arg ) = @_;

  state $input_dir = tempdir();
  state $dest_dir  = tempdir();

  my $file = join '/' , $input_dir , $arg{file};

  open( my $OUT , '>' , $file ) or die $!;
  print $OUT $arg{content};
  close( $OUT );

  return HiD::Page->new({
    dest_dir       => $dest_dir,
    hid            => HiD->new({config => {}}),
    input_filename => $file ,
    layouts        => $arg{layouts} ,
    source         => $input_dir,
  });
}

sub make_post {
  my( %arg ) = @_;

  state $posts_dir = tempdir();
  state $dest_dir  = tempdir();

  my @path_parts = ( $posts_dir );

  push @path_parts , '_posts'
    unless ( $arg{file} =~ m|/_posts/| );

  my $file = join '/' , @path_parts , $arg{file};

  my( undef , $dir ) = fileparse( $file );
  make_path $dir unless -d $dir;

  open( my $OUT , '>' , $file ) or die $!;
  print $OUT $arg{content};
  close( $OUT );

  return HiD::Post->new({
    dest_dir       => $dest_dir,
    hid            => HiD->new({config => {}}) ,
    input_filename => $file ,
    layouts        => $arg{layouts} ,
    source         => $posts_dir,
  });
}


1;
