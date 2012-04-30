package Hyde;
# ABSTRACT: Static website generation system
use Mouse;
extends 'MouseX::App::Cmd';

=head1 SYNOPSIS

See C<perldoc hyde> for usage information.

=cut

use namespace::autoclean;

use autodie       qw/ :all /;
use Class::Load   qw/ :all /;
use Hyde::Layout;
use Hyde::Types;
use YAML::XS      qw/ LoadFile /;

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

has layout_dir => (
  is      => 'ro' ,
  isa     => 'Str' ,
  default => '_layouts' ,
);

has layouts => (
  is      => 'ro' ,
  isa     => 'HashRef[Hyde::Layout]',
  lazy    => 1 ,
  builder => '_build_layouts'
);

sub _build_layouts {
  my $self = shift;

  my %layouts;

  opendir( my $layout_dh , $self->layout_dir );
  ### FIXME deal with recursion...
  while ( my $layout_file = readdir $layout_dh ) {
    next if $layout_file =~ /^\./;
    next if -d $layout_file;

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

has pages => ( is => 'ro' );

has posts => ( is => 'ro' );

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
