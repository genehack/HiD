package HiD::Role::IsProcessed;
use Mouse::Role;

use namespace::autoclean;

use autodie;
use Carp;
use Class::Load  qw/ :all /;
use HiD::Types;
use Path::Class  qw/ file /;
use YAML::XS     qw/ Load /;

=attr content

=cut

has content => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1 ,
  builder => '_build_content' ,
);

sub _build_content {
  my $self = shift;

  open( my $IN , '<' , $self->filename );

  my( $content , $metadata );

  my $first = <$IN>;

  confess "no front matter" . $self->filename unless $first =~ /^---$/;

  if ( $first =~ /^---$/ ) {
    my $line = <$IN>;
    while ( $line !~ /^---$/ ) {
      $metadata .= $line;
      $line = <$IN>;
    }
    $self->_set_metadata( Load($metadata));
  }
  else {
    $content = $first ;
    $self->_set_metadata( {} );
  }

  {
    local $/;
    $content .= <$IN>;
  }

  close( $IN );

  return $content;
}

=attr layout

=cut

has layout => (
  is      => 'ro' ,
  isa     => 'HiD::Layout' ,
  lazy    => 1 ,
  builder => '_build_layout' ,
);

sub _build_layout {
  my $self = shift;

  my $layout_name = $self->get_metadata( 'layout' ) // 'default';

  return $self->get_layout_by_name( $layout_name );
}

=attr metadata

=cut

has metadata => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  default => sub {{}} ,
  lazy    => 1,
  traits  => [ 'Hash' ] ,
  writer  => '_set_metadata',
  handles => {
    get_metadata => 'get',
  },
);

=attr permalink

=cut

has permalink => (
  is      => 'ro' ,
  isa     => 'Maybe[Str]' ,
  lazy    => 1 ,
  builder => '_build_permalink' ,
);

sub _build_permalink {
  my $self = shift;
  return $self->get_metadata( 'permalink' );
}

=attr processed_content

=cut

has processed_content => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => '_build_processed_content' ,
);

sub _build_processed_content {
  my $self = shift;

  my %extensions = (
    markdown => [ 'Text::Markdown' , 'markdown' ] ,
    mkdn     => [ 'Text::Markdown' , 'markdown' ] ,
    mk       => [ 'Text::Markdown' , 'markdown' ] ,
    textile  => [ 'Text::Textile'  , 'process'  ] ,
  );

  return $self->content unless exists $extensions{$self->extension};

  my( $module , $method ) = @{ $extensions{ $self->extension }};
  load_class( $module );

  return $module->new->$method( $self->content );
}

sub processing_data {
  my $self = shift;

  my $return = {
    content  => $self->processed_content ,
    metadata => $self->metadata ,
  };

  foreach my $method( qw/ title url / ) {
    $return->{$method} = $self->$method
      if $self->can( $method );
  }

  return $return;
}


no Mouse::Role;
1;
