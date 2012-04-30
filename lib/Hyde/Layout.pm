package Hyde::Layout;
# ABSTRACT: Class representing a particular layout
use Mouse;

use namespace::autoclean;

use File::Slurp qw/ read_file / ;
use Hyde::Types;
use Mouse::Util::TypeConstraints;
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
  isa      => 'Str' ,
  required => 1 ,
);

=attr filename

=cut

has filename => (
  is       => 'ro' ,
  isa      => 'File' ,
  required => 1 ,
);

=attr layout

=cut

has layout => (
  is     => 'rw' ,
  isa    => 'Maybe[Object]' ,
  writer => 'set_layout' ,
);

=attr metadata

=cut

has metadata => (
  is  => 'ro' ,
  isa => 'Maybe[HashRef]'
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

has processor => ( is => 'ro' );


sub BUILDARGS {
  my $class = shift;

  my %args = ( ref $_[0] and ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  ( $args{name} , $args{extension} ) = $args{filename}
    =~ m|^.*/(.+)\.([^.]+)$|;

  my $content = read_file( $args{filename} );

  my $meta;
  if ( $content =~ /^---\n/s ) {
    ( $meta , $content ) = ( $content )
      =~ m|^---\n(.*?)---\n(.*)$|s;
  }

  $args{metadata} = Load( $meta ) if $meta;
  $args{content}  = $content;

  return \%args;
}


__PACKAGE__->meta->make_immutable;
1;
