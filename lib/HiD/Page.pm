package HiD::Page;
use Mouse;
use namespace::autoclean;

use HiD::Types;

use YAML::XS qw/ Load /;

=attr content

=cut

has content => (
  is       => 'ro',
  isa      => 'Str',
  required => 1 ,
);

=attr destination

=cut

has destination => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

=attr extension

=cut

has extension => (
  is       => 'ro' ,
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
  is       => 'ro' ,
  isa      => 'HiD::Layout' ,
  required => 1 ,
);

=attr metadata

=cut

has metadata => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  default => sub {{}} ,
);

=attr processed_content

=cut

has processed_content => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => 'process_content' ,
);

=attr title

=cut

has title => (
  is       => 'ro' ,
  isa      => 'Str' ,
  # TODO decide about this -> required => 1 ,
);

sub BUILDARGS {
  my $class = shift;

  my %args = ( ref $_[0] && ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  die "filename required for page"
    unless $args{filename};

  die "hid required for page"
    unless $args{hid};

  $args{destination} = join '/' , $args{hid}->site_dir , $args{filename};

  my( $extension ) = $args{filename}
    =~ m|^(?:.+?)\.(.+)$|;

  $args{extension} = $extension;

  my $metadata;
  open( my $IN , '<' , $args{filename} );
  my $first = <$IN>;

  # things that call HiD::Page->new() should be prepared to deal with this...
  # TODO: should document that...
  die "no YAML front matter"
    unless $first =~ /^---$/;

  my $line = <$IN>;
  while ( $line !~ /^---$/ ) {
    $metadata .= $line;
    $line = <$IN>;
  }

  # FIXME handle exceptions;
  $args{metadata} = Load($metadata);

  {
    local $/;
    $args{content} .= <$IN>;
  }

  close( $IN );

  $args{title} = ( ref $args{metadata}{title} )
    ? ${$args{metadata}{title} }
      : $args{metadata}{title}  // 'NO TITLE';

  my $layout_name = $args{metadata}{layout} // 'default';
  $args{layout} = $args{hid}->get_layout_by_name( $layout_name );

  return \%args;
}

sub processing_data {
  my $self = shift;

  return {
    content  => $self->content ,
    title    => $self->title ,
    metadata => $self->metadata ,
  }
}

__PACKAGE__->meta->make_immutable;
1;
