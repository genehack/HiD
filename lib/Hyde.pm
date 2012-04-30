package Hyde;
# ABSTRACT: Static website generation system
use Mouse;
extends 'MouseX::App::Cmd';

=head1 SYNOPSIS

See C<perldoc hyde> for usage information.

=cut

use namespace::autoclean;

use autodie            qw/ :all /;
use Class::Load        qw/ :all /;
use File::Find::Rule;
use Hyde::Layout;
use Hyde::Page;
use Hyde::Post;
use Hyde::Types;
use YAML::XS           qw/ LoadFile /;

has config => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  lazy    => 1 ,
  builder => '_build_config' ,
);

sub _build_config {
  my $file = shift->config_file;
  # FIXME error handling?
  return -e -f -r $file ? LoadFile $file : {};
}

has config_file => (
  is      => 'ro' ,
  isa     => 'Str' ,
  default => '_config.yml' ,
);

has files => (
  is      => 'ro' ,
  isa     => 'HashRef',
  default => sub {{}} ,
  traits  => ['Hash'],
  handles => {
    add_file  => 'set' ,
    seen_file => 'exists' ,
  },
);

has layout_dir => (
  is      => 'ro' ,
  isa     => 'Hyde::Dir' ,
  default => '_layouts' ,
);

has layouts => (
  is      => 'ro' ,
  isa     => 'HashRef[Hyde::Layout]',
  lazy    => 1 ,
  builder => '_build_layouts',
  traits  => ['Hash'] ,
  handles => {
    get_layout_by_name => 'get' ,
  },
);

sub _build_layouts {
  my $self = shift;

  my %layouts;

  opendir( my $layout_dh , $self->layout_dir );
  ### FIXME deal with recursion...
  while ( my $layout_file = readdir $layout_dh ) {
    next if $layout_file =~ /^\./;
    next if -d $layout_file;

    $self->add_file( $self->layout_dir . "/$layout_file" => 'layout' );

    my( $layout_name ) = $layout_file =~ /^(.*)\.[^.]+$/;

    $layouts{$layout_name} = Hyde::Layout->new({
      filename => $self->layout_dir . "/$layout_file"
    });
  }

  foreach my $layout_name ( keys %layouts ) {
    my $metadata = $layouts{$layout_name}->metadata;

    if ( my $embedded_layout = $metadata->{layout} ) {
      die "FIXME embedded layout fail"
        unless $layouts{$embedded_layout};

      $layouts{$layout_name}->set_layout( $layouts{$embedded_layout} );
    }
  }

  return \%layouts;
}

has page_file_regex => (
  is      => 'ro' ,
  isa     => 'RegexpRef',
  default => sub { qr/\.(mk|mkd|mkdn|markdown|html)$/ } ,
);

has pages => (
  is      => 'ro',
  isa     => 'Maybe[ArrayRef[Hyde::Page]]',
  lazy    => 1 ,
  builder => '_build_pages' ,
);

sub _build_pages {
  my $self = shift;

  # build posts before pages
  $self->posts;

  my @potential_pages = File::Find::Rule->file->nonempty
    ->name( $self->page_file_regex )->in( '.' );

  my @pages = grep { $_ } map {
    if ($self->seen_file( $_ )) { 0 }
    else {
      $self->add_file( $_ => 'page' );
      Hyde::Page->new( filename => $_ , hyde => $self );
    }
  } @potential_pages;

  return \@pages;
}

has post_file_regex => (
  is      => 'ro' ,
  isa     => 'RegexpRef' ,
  default => sub { qr/^[0-9]{4}-[0-9]{2}-[0-9]{2}-(?:.+?)\.(?:mk|mkd|mkdn|markdown)$/ },
);

has posts_dir => (
  is      => 'ro' ,
  isa     => 'Hyde::Dir' ,
  default => '_posts' ,
);

has posts => (
  is      => 'ro' ,
  isa     => 'Maybe[ArrayRef[Hyde::Post]]' ,
  lazy    => 1 ,
  builder => '_build_posts' ,
);

sub _build_posts {
  my $self = shift;

  # build layouts before posts
  $self->layouts;

  my @potential_posts = File::Find::Rule->file->nonempty
    ->name( $self->post_file_regex )->in( $self->posts_dir );

  my @posts = map { my $post = Hyde::Post->new( filename => $_ , hyde => $self );
                    $self->add_file( $_ => 'post' ); $post } @potential_posts;

  return \@posts;
}

has processor => (
  is      => 'ro' ,
  isa     => 'Hyde::Processor' ,
  lazy    => 1 ,
  builder => '_build_processor' ,
);

sub _build_processor {
  my $self = shift;

  my $processor_name  = $self->config->{processor_name} // 'Template';

  my $processor_class = ( $processor_name =~ /^\+/ ) ? $processor_name
    : "Hyde::Processor::$processor_name";

  try_load_clas( $processor_class );

  return $processor_class->new( $self->config->{processor_args} );
}

__PACKAGE__->meta->make_immutable;
1;
