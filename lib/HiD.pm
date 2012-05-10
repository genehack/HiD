package HiD;
# ABSTRACT: Static website publishing framework
use Moose;
use namespace::autoclean;

use Class::Load        qw/ :all /;
use File::Basename;
use File::Find::Rule;
use File::Path         qw/ make_path /;
use File::Remove       qw/ remove /;
use HiD::File;
use HiD::Layout;
use HiD::Page;
use HiD::Post;
use HiD::Types;
use Path::Class        qw/ file /;
use Try::Tiny;
use YAML::XS           qw/ LoadFile /;

=attr config

=cut

has config => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  traits  => [ 'Hash' ],
  lazy    => 1 ,
  builder => '_build_config' ,
  handles => {
    get_config => 'get' ,
  }
);

sub _build_config {
  my $file = shift->config_file;

  my $config;
  try { $config = LoadFile( $file ) ; ref $config eq 'HASH' or die }
  catch {
    warn "WARNING: Could not read configuration. Using defaults (and options).\n";
    $config = {};
  };

  return $config;
}

=attr config_file

=cut

has config_file => (
  is      => 'ro' ,
  isa     => 'Str' ,
  default => '_config.yml' ,
);

=attr destination

=cut

has destination => (
  is      => 'ro' ,
  isa     => 'HiD_DirPath' ,
  lazy    => 1 ,
  default => sub {
    my $dest = shift->get_config( 'destination' ) // '_site';
    make_path $dest unless -e -d $dest;
    return $dest;
  },
);

=attr include_dir

=cut

has include_dir => (
  is      => 'ro' ,
  isa     => 'Maybe[HiD_DirPath]' ,
  lazy    => 1,
  default => sub {
    my $self = shift;
    $self->get_config( 'include_dir' ) //
      ( -e -d '_includes' ) ? '_includes' : undef;
  } ,
);

=attr inputs

=cut

has inputs => (
  is      => 'ro' ,
  isa     => 'HashRef',
  default => sub {{}} ,
  traits  => ['Hash'],
  handles => {
    add_input  => 'set' ,
    seen_input => 'exists' ,
  },
);

=attr layout_dir

=cut

has layout_dir => (
  is      => 'ro' ,
  isa     => 'HiD_DirPath' ,
  lazy    => 1 ,
  default => sub { shift->get_config( 'layout_dir' ) // '_layouts' } ,
);

=attr layouts

=cut

has layouts => (
  is      => 'ro' ,
  isa     => 'HashRef[HiD::Layout]',
  lazy    => 1 ,
  builder => '_build_layouts',
  traits  => ['Hash'] ,
  handles => {
    get_layout_by_name => 'get' ,
  },
);

sub _build_layouts {
  my $self = shift;

  my @layout_files = File::Find::Rule->file
    ->in( $self->layout_dir );

  my %layouts;
  foreach my $layout_file ( @layout_files ) {
    my $dir = $self->layout_dir;

    my( $layout_name , $extension ) = $layout_file
      =~ m|^$dir/(.*)\.([^.]+)$|;

    $layouts{$layout_name} = HiD::Layout->new({
      filename  => $layout_file,
      processor => $self->processor ,
    });

    $self->add_input( $layout_file => 'layout' );
  }

  foreach my $layout_name ( keys %layouts ) {
    my $metadata = $layouts{$layout_name}->metadata;

    if ( my $embedded_layout = $metadata->{layout} ) {
      die "FIXME embedded layout fail $embedded_layout"
        unless $layouts{$embedded_layout};

      $layouts{$layout_name}->set_layout(
        $layouts{$embedded_layout}
      );
    }
  }

  return \%layouts;
}

=attr objects

=cut

has objects => (
  is  => 'ro' ,
  isa => 'ArrayRef[Object]' ,
  traits => [ 'Array' ] ,
  default => sub{[]} ,
  handles => {
    add_object  => 'push' ,
    all_objects => 'elements' ,
  },
);

=attr page_file_regex

=cut

has page_file_regex => (
  is      => 'ro' ,
  isa     => 'RegexpRef',
  default => sub { qr/\.(mk|mkd|mkdn|markdown|textile|html)$/ } ,
);

=attr pages

=cut

has pages => (
  is      => 'ro',
  isa     => 'Maybe[ArrayRef[HiD::Page]]',
  lazy    => 1 ,
  builder => '_build_pages' ,
);

sub _build_pages {
  my $self = shift;

  # build posts before pages
  $self->posts;

  my @potential_pages = File::Find::Rule->file->
    name( $self->page_file_regex )->in( '.' );

  my @pages = grep { $_ } map {
    if ($self->seen_input( $_ ) or $_ =~ /^_/ ) { 0 }
    else {
      try {
        my $page = HiD::Page->new({
          dest_dir       => $self->destination,
          input_filename => $_ ,
          layouts        => $self->layouts ,
        });
        $page->content;
        $self->add_input( $_ => 'page' );
        $self->add_object( $page );
        $page;
      }
      catch { 0 };
    }
  } @potential_pages;

  return \@pages;
}

=attr post_file_regex

=cut

has post_file_regex => (
  is      => 'ro' ,
  isa     => 'RegexpRef' ,
  default => sub { qr/^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}-(?:.+?)\.(?:mk|mkd|mkdn|markdown|md|text|textile|html)$/ },
);

=attr posts_dir

=cut

has posts_dir => (
  is      => 'ro' ,
  isa     => 'HiD_DirPath' ,
  lazy    => 1 ,
  default => '_posts' ,
);

=attr posts

=cut

has posts => (
  is      => 'ro' ,
  isa     => 'Maybe[ArrayRef[HiD::Post]]' ,
  lazy    => 1 ,
  builder => '_build_posts' ,
);

sub _build_posts {
  my $self = shift;

  # build layouts before posts
  $self->layouts;

  my $rule = File::Find::Rule->new;

  my @posts_directories = $rule->or(
    $rule->new->directory->name( '_posts' ) ,
      $rule->new->directory->name( '_site' )->prune->discard ,
  )->in( $self->source );

  my @potential_posts = File::Find::Rule->file
    ->name( $self->post_file_regex )->in( @posts_directories );

  my @posts = grep { $_ } map {
    try {
      my $post = HiD::Post->new({
        dest_dir       => $self->destination,
        input_filename => $_ ,
        layouts        => $self->layouts ,
      });
      $self->add_input( $_ => 'post' );
      $self->add_object( $post );
      $post
    } catch { 0 };
  } @potential_posts;

  return \@posts;
}

=attr processor

=cut

has processor => (
  is      => 'ro' ,
  isa     => 'HiD::Processor' ,
  lazy    => 1 ,
  default => sub {
    my $self = shift;

    my $processor_name  = $self->get_config( 'processor_name' ) // 'Template';

    my $processor_class = ( $processor_name =~ /^\+/ ) ? $processor_name
      : "HiD::Processor::$processor_name";

    try_load_class( $processor_class );

    return $processor_class->new( $self->processor_args );
  },
);

has processor_args => (
  is      => 'ro' ,
  isa     => 'ArrayRef|HashRef' ,
  lazy    => 1 ,
  default => sub {
    my $self = shift;

    return $self->get_config( 'processor_args' ) if
      defined $self->get_config( 'processor_args' );

    my $include_path = $self->layout_dir;
    $include_path   .= ':' . $self->include_dir
      if defined $self->include_dir;

    return {
      INCLUDE_PATH => $include_path ,
    };
  },
);

=attr regular_files

=cut

has regular_files => (
  is      => 'ro',
  isa     => 'Maybe[ArrayRef[HiD::File]]',
  lazy    => 1 ,
  builder => '_build_regular_files' ,
);

sub _build_regular_files {
  my $self = shift;

  # build pages before regular files
  $self->pages;

  my @potential_files = File::Find::Rule->file->in( '.' );

  my @files = grep { $_ } map {
    if ($self->seen_input( $_ ) or $_ =~ /^_/ ) { 0 }
    else {
      my $file = HiD::File->new({
        dest_dir       => $self->destination,
        input_filename => $_ ,
      });
      $self->add_input( $_ => 'file' );
      $self->add_object( $file );
      $file;
    }
  } @potential_files;

  return \@files;
}

=attr source

=cut

has source => (
  is      => 'ro' ,
  isa     => 'HiD_DirPath' ,
  lazy    => 1 ,
  default => sub {
    my $self   = shift;
    my $source = $self->get_config( 'source') // '.';
    chdir $source or die $!;
    return $source;
  },
);

__PACKAGE__->meta->make_immutable;
1;
