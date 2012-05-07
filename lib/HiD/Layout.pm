package HiD::Layout;
# ABSTRACT: Class representing a particular layout
use Moose;

use namespace::autoclean;

use File::Slurp qw/ read_file / ;
use HiD::Types;
use YAML::XS;

=attr content

=cut

has content => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

=attr extension

=cut

has extension => (
  is       => 'ro'  ,
  isa      => 'HiD_FileExtension' ,
  required => 1 ,
);

=attr filename

=cut

has filename => (
  is       => 'ro' ,
  isa      => 'HiD_FilePath' ,
  required => 1 ,
);

=attr layout

=cut

has layout => (
  is     => 'rw' ,
  isa    => 'Maybe[HiD::Layout]' ,
  writer => 'set_layout' ,
);

=attr metadata

=cut

has metadata => (
  is  => 'ro' ,
  isa => 'HashRef'
);

=attr name

=cut

has name => (
  is       => 'ro'  ,
  isa      => 'Str' ,
  required => 1 ,
);

=attr processor

=cut

has processor => (
  is       => 'ro',
  isa      => 'Object' ,
  required => 1 ,
);


sub BUILDARGS {
  my $class = shift;

  my %args = ( ref $_[0] and ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  ( $args{name} , $args{extension} ) = $args{filename}
    =~ m|^.*/(.+)\.([^.]+)$|;

  my $content  = read_file( $args{filename} );
  my $metadata = {};

  if ( $content =~ /^---\n/s ) {
    my $meta;
    ( $meta , $content ) = ( $content )
      =~ m|^---\n(.*?)---\n(.*)$|s;
    $metadata = Load( $meta ) if $meta;
  }

  $args{metadata} = $metadata;
  $args{content}  = $content;

  return \%args;
}

sub process {
  my( $self , $data , $output ) = @_;

  $self->processor->process(
    $self->filename ,
    $data ,
    $output ,
  ) or die $self->processor->error;
}


__PACKAGE__->meta->make_immutable;
1;
