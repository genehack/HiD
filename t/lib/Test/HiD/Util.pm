package Test::HiD::Util;
use 5.014;
use warnings;

use Path::Tiny   qw/ path tempdir /;
use Template;
use YAML::Tiny;

use HiD;
use HiD::Layout;
use HiD::Page;
use HiD::Post;

use Exporter 'import';
our @EXPORT_OK = qw/ make_layout make_page make_post write_bad_config write_config write_fixture_file /;

sub make_layout {
  my( %arg ) = @_;

  state $template = Template->new( ABSOLUTE => 1 );

  my $file = Path::Tiny->tempfile( SUFFIX => '.html' );
  $file->spew_utf8( $arg{content} );

  my $layout_args = {
    filename  => $file->stringify() ,
    processor => $template ,
  };
  $layout_args->{layout} = $arg{layout} if $arg{layout};

  return HiD::Layout->new( $layout_args );
}

sub make_page {
  my( %arg ) = @_;

  my $input_dir    = $arg{dir} // tempdir();
  state $dest_dir  = tempdir();

  path( $input_dir )->mkpath;

  my $file = path( $input_dir , $arg{file} );
  $file->spew_utf8($arg{content});

  return HiD::Page->new({
    dest_dir       => $dest_dir->stringify(),
    hid            => HiD->new({config => {}}),
    input_filename => $file->stringify() ,
    layouts        => $arg{layouts} ,
    source         => $input_dir,
  });
}

sub make_post {
  my( %arg ) = @_;

  my $posts_dir    = $arg{dir} // tempdir();
  state $dest_dir  = tempdir();

  my @path_parts = ( $posts_dir );

  push @path_parts , '_posts'
    unless ( $arg{file} =~ m|/_posts/| or $arg{dir} =~ m|/_posts| );

  my $file = path( @path_parts , $arg{file} );

  my $dir = $file->parent;
  $dir->mkpath() unless $dir->is_dir();

  $file->spew_utf8( $arg{content} );

  return HiD::Post->new({
    dest_dir       => $dest_dir->stringify(),
    hid            => HiD->new({config => {}}) ,
    input_filename => $file->stringify() ,
    layouts        => $arg{layouts} ,
    source         => $posts_dir,
  });
}

sub write_bad_config {
  my $data = shift;
  my $fh   = path('_config.yml')->spew_utf8( $data );
}

sub write_config {
  my $data = shift;
  my $yaml = YAML::Tiny->new($data);
  $yaml->write('_config.yml');
}

sub write_fixture_file {
  my( $file , $content ) = @_;
  path( $file )->spew_utf8( $content );
}

1;
