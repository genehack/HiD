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

=attr ext

=cut

has ext => (
  is       => 'ro'  ,
  isa      => 'HiD_FileExtension' ,
);

=attr filename

=cut

has filename => (
  is       => 'ro' ,
  isa      => 'HiD_FilePath' ,
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
  is      => 'ro' ,
  isa     => 'HashRef',
  lazy    => 1 ,
  default => sub {{}}
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

  unless ( $args{content} ) {
    ( $args{name} , $args{ext} ) = $args{filename}
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
  }

  return \%args;
}

=method render

Pass in a hash of data, apply the layout using that hash as input, and return
the resulting output string.

Will recurse into embedded layouts as needed.

=cut

sub render {
  my( $self , $data ) = @_;

  my $page_data = $data->{page} // {};

  %{ $data->{page} } = (
    %{ $self->metadata } ,
    %{ $page_data },
  );

  my $processed_input_content;
  my $input_content = delete $data->{content};

  $self->processor->process(
    \$input_content ,
    $data ,
    \$processed_input_content ,
  );

  $data->{content} = $processed_input_content;

  my $output;

  $self->processor->process(
    \$self->content ,
    $data ,
    \$output ,
  ) or die $self->processor->error;

  if ( my $embedded_layout = $self->layout ) {
    $data->{content} = $output;
    $output = $embedded_layout->render( $data );
  }

  return $output;
}

__PACKAGE__->meta->make_immutable;
1;
