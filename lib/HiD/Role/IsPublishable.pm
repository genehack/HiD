package HiD::Role::IsPublishable;
use Mouse::Role;

use namespace::autoclean;

use HiD::Types;
use Path::Class qw/ file / ;

requires 'publish';

=attr destination

=cut

has destination => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => '_build_destination'  ,
);

sub _build_destination {
  my $self = shift;

  my $filename = $self->filename;

  if ( $self->can( 'permalink') and my $permalink = $self->permalink ) {
    $filename = $permalink;
    $filename .= 'index.html' if ( $filename =~ m|/$| );
  }
  elsif ( $self->extension ne 'html' && $self->does( 'HiD::Role::IsProcessed' )) {
    my $ext = $self->extension;
    $filename =~ s/$ext$/html/;
  }

  return file( $self->site_dir , $filename )->stringify;
}

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
  isa      => 'HiD::Config',
  required => 1 ,
  handles  => {
    get_layout_by_name => 'get_layout_by_name' ,
    process            => 'process' ,
    site_dir           => 'site_dir' ,
  } ,
);

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
  my $url = $self->destination;
  my $site_dir = $self->site_dir;
  $url =~ s|^$site_dir||;
  $url =~ s|index.html$||;
  return $url;
}

no Mouse::Role;
1;
