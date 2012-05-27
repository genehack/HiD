# ABSTRACT: Class representing a particular layout

=head1 SYNOPSIS

    my $layout = HiD::Layout->new({
      filename  => $path_to_file ,
      processor => $hid_processor_object ,
    });

=head1 DESCRIPTION

Class representing layout files.

=cut

package HiD::Layout;
use Moose;
use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

use File::Slurp qw/ read_file / ;
use HiD::Types;
use YAML::XS;

=attr content

Content of this layout.

=cut

has content => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

=attr ext

File extension of this layout.

=cut

has ext => (
  is       => 'ro'  ,
  isa      => 'HiD_FileExtension' ,
);

=attr filename

Filename of this layout.

=cut

has filename => (
  is       => 'ro' ,
  isa      => 'HiD_FilePath' ,
);

=attr layout

Name of a layout that will be used when processing this layout. (Can be
applied recursively.)

=cut

has layout => (
  is     => 'rw' ,
  isa    => 'Maybe[HiD::Layout]' ,
  writer => 'set_layout' ,
);

=attr metadata

Metadata for this layout. Populated from the YAML front matter in the layout
file.

=cut

has metadata => (
  is      => 'ro' ,
  isa     => 'HashRef',
  lazy    => 1 ,
  default => sub {{}}
);

=attr name

Name of the layout.

=cut

has name => (
  is       => 'ro'  ,
  isa      => 'Str' ,
  required => 1 ,
);

=attr processor

Processor object used to process content through this layout when rendering.

=cut

has processor => (
  is       => 'ro',
  isa      => 'Object' ,
  required => 1 ,
  handles  => {
    process_template => 'process' ,
    processor_error  => 'error' ,
  },
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

  $self->process_template(
    \$input_content ,
    $data ,
    \$processed_input_content ,
  ) or die $self->processor_error;

  $data->{content} = $processed_input_content;

  my $output;

  $self->process_template(
    \$self->content ,
    $data ,
    \$output ,
  ) or die $self->processor_error;

  if ( my $embedded_layout = $self->layout ) {
    $data->{content} = $output;
    $output = $embedded_layout->render( $data );
  }

  return $output;
}

__PACKAGE__->meta->make_immutable;
1;
