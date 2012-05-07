package HiD::Role::IsPublishable;
use Mouse::Role;

use namespace::autoclean;

use HiD::Types;
use Path::Class qw/ file / ;

requires 'publish';

=attr extension

=cut

has extension => (
  is      => 'ro' ,
  isa     => 'HiD_FileExtension' ,
  lazy    => 1 ,
  builder => '_build_extension' ,
);

sub _build_extension {
  my $self = shift;

  my( $extension ) = $self->filename =~ m|\.([^.]+)$|;

  return $extension;
}

=attr filename

=cut

has filename => (
  is       => 'ro' ,
  isa      => 'HiD_FilePath' ,
  required => 1 ,
);

=attr hid

=cut

has hid => (
  is       => 'ro' ,
  isa      => 'HiD',
  required => 1 ,
  handles  => {
    destination        => 'destination' ,
    get_layout_by_name => 'get_layout_by_name' ,
    process            => 'process' ,
  } ,
);

has output_filename => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => '_build_output_filename'  ,
);

sub _build_output_filename {
  my $self = shift;

  my $filename = $self->filename;

  if ( $self->can( 'permalink' ) and my $permalink = $self->permalink ) {
    $filename = $permalink;
    $filename .= 'index.html' if ( $filename =~ m|/$| );
  }
  elsif ( $self->extension ne 'html' && $self->does( 'HiD::Role::IsProcessed' )) {
    my $ext = $self->extension;
    $filename =~ s/$ext$/html/;
  }

  return file( $self->destination , $filename )->stringify;
}

=attr url

=cut

has url => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => '_build_url' ,
);

sub _build_url {
  my $self = shift;
  my $url  = $self->output_filename;
  my $destination = $self->destination;
  $url =~ s|^$destination||;
  $url =~ s|index.html$||;
  return $url;
}

no Mouse::Role;
1;
