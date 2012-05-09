package HiD::Role::IsConverted;
use Moose::Role;

use namespace::autoclean;

use Carp;
use Class::Load  qw/ :all /;
use HiD::Types;
use YAML::XS     qw/ Load /;

=attr content ( ro / Str / required )

Page content (stuff after the YAML front matter)

=cut

has content => (
  is       => 'ro',
  isa      => 'Str',
  required => 1 ,
);

=attr converted_content ( ro  / Str / lazily built from content )

Content after it has gone through the conversion process.

=cut

my %conversion_extension_map = (
  markdown => [ 'Text::Markdown' , 'markdown' ] ,
  mkdn     => [ 'Text::Markdown' , 'markdown' ] ,
  mk       => [ 'Text::Markdown' , 'markdown' ] ,
  textile  => [ 'Text::Textile'  , 'process'  ] ,
);

has converted_content => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  default => sub {
    my $self = shift;

    return $self->content
      unless exists $conversion_extension_map{ $self->ext };

    my( $module , $method ) =
      @{ $conversion_extension_map{ $self->ext }};
    load_class( $module );

    return $module->new->$method( $self->content );
  },
);

=attr layouts ( ro / HashRef[HiD::Layout] / required )

Hashref of layout objects

=cut

has layouts => (
  is       => 'ro' ,
  isa      => 'HashRef[HiD::Layout]' ,
  required => 1 ,
);

=attr metadata ( ro / HashRef )

Hashref of info from YAML front matter

=cut

has metadata => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  default => sub {{}} ,
  lazy    => 1,
  traits  => [ 'Hash' ] ,
  handles => {
    get_metadata => 'get',
  },
);

=attr rendered_content

Content after any layouts have been applied

=cut

has rendered_content => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  default => sub {
    my $self = shift;

    my $layout_name = $self->get_metadata( 'layout' ) // 'default';

    my $layout = $self->layouts->{$layout_name};

    my $output = $layout->render( $self->template_data );

    return $output;
  }
);

=attr template_data

Data for passing to template processing function.

=cut

has template_data => (
  is     => 'ro' ,
  isa     => 'HashRef' ,
  lazy    => 1 ,
  default => sub {
    my $self = shift;

    my $data = {
      content  => $self->converted_content ,
      page     => $self->metadata ,
    };

    foreach my $method ( qw/ title url / ) {
      $data->{page}{$method} = $self->$method
        if $self->can( $method );
    }

    return $data;
  },
);

sub BUILDARGS {}

around 'BUILDARGS' => sub {
  my $orig  = shift;
  my $class = shift;

  my %args = ( ref $_[0] and ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  unless ( $args{content} and $args{metadata} ) {
    open( my $IN , '<' , $args{input_filename} )
      or confess "$! $args{input_filename}";

    my $first = <$IN>;

    confess 'no front matter in ' . $args{input_filename}
      unless $first =~ /^---$/;

    my $file_content;
    {
      local $/;
      $file_content .= <$IN>;
    }
    close( $IN );

    my( $metadata , $content ) = split /---\n/ , $file_content;

    $args{content}  = $content;
    $args{metadata} = Load( $metadata ) // {};
  }

  return \%args;
};

no Moose::Role;
1;
