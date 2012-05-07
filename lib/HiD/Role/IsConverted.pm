package HiD::Role::IsConverted;
use Mouse::Role;

use namespace::autoclean;

use Carp;
use Class::Load  qw/ :all /;
use HiD::Types;
use Path::Class  qw/ file /;
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

=attr permalink

Format strung to build permalink

=cut

has permalink => (
  is      => 'ro' ,
  isa     => 'Maybe[Str]' ,
  lazy    => 1 ,
  # do this as a builder so we can override it
  builder => '_build_permalink' ,
);

sub _build_permalink { shift->get_metadata( 'permalink' ) }

sub BUILDARGS {}

around 'BUILDARGS' => sub {
  my $orig  = shift;
  my $class = shift;

  my %args = ( ref $_[0] and ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  unless ( $args{content} and $args{metadata} ) {
    open( my $IN , '<' , $args{input_filename} ) or die $!;

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

=method template_data

Hashref of data suitable for passing to template processing function.

=cut

sub template_data {
  my $self = shift;

  my $data = {
    content  => $self->converted_content ,
    page     => $self->metadata ,
  };

  foreach my $method( qw/ title url / ) {
    $data->{page}{$method} = $self->$method
      if $self->can( $method );
  }

  return $data;
}

no Mouse::Role;
1;
