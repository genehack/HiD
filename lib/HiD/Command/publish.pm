package HiD::Command::publish;
use 5.010;
use Mouse;
extends 'HiD::Command';

use File::Basename;
use File::Copy;
use File::Path       qw/ make_path /;

has written_files => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  traits  => [ 'Hash' ] ,
  default => sub {{}},
  handles => {
    add_written_file  => 'set' ,
    written_file      => 'get' ,
    all_written_files => 'keys' ,
  },
);

sub execute {
  my $self = shift;

  _publish_posts( $self );
  _publish_pages( $self );
  _publish_regular_files( $self );

  foreach ( File::Find::Rule->file->in( $self->hid->site_dir )) {
    unlink $_ unless defined $self->written_file($_)
  }
}

sub _publish_pages {
  my $self = shift;

  my @pages = @{ $self->hid->pages };

  foreach my $page ( @pages ) {

    my $layout = $page->layout->name;

    $self->hid->process(
      ### FIXME just ... gross.
      $page->layout->name . '.' . $page->layout->extension,
      $page->processing_data ,
      $page->destination ,
      ### FIXME also nasty...
    ) or die $self->hid->processor->tt->error;

    $self->add_written_file( $page->destination , 1 );
  }
}

sub _publish_posts {
  my $self = shift;

  my @posts = @{ $self->hid->posts };

  foreach my $post ( @posts ) {
    $self->hid->process(
      ### FIXME just ... gross.
      $post->layout->name . '.' . $post->layout->extension,
      $post->processing_data ,
      $post->destination ,
      ### FIXME also nasty...
    ) or die $self->hid->processor->tt->error;

    $self->add_written_file( $post->destination , 1 );
  }
}

sub _publish_regular_files {
  my $self = shift;

  foreach my $file ( @{ $self->hid->regular_files } ) {
    my( undef , $dir ) = fileparse( $file->destination );
    make_path $dir unless -d $dir;

    copy( $file->filename , $file->destination ) or die $!;
    $self->add_written_file( $file->destination , 1 )
  }
}

__PACKAGE__->meta->make_immutable;
1;
