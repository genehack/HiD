# ABSTRACT: Role for objects that are converted during the publishing process

=head1 SYNOPSIS

    package HiD::ThingThatIsConverted
    use Moose;
    with 'HiD::Role::IsConverted';

    ...

    1;

=head1 DESCRIPTION

This role is consumed by objects that are converted during the publication
process -- e.g., from Markdown or Textile to HTML, or rendered through a
layout object. This role provides required attributes and methods used during
that process.

=cut

package HiD::Role::IsConverted;
use Moose::Role;
use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

use Carp;
use Class::Load  qw/ :all /;
use HiD::Types;
use YAML::XS     qw/ Load /;

requires 'get_default_layout';

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

### FIXME make this extensible
my %conversion_extension_map = (
  markdown => [ 'Text::Markdown' , 'markdown' ] ,
  mkdn     => [ 'Text::Markdown' , 'markdown' ] ,
  mk       => [ 'Text::Markdown' , 'markdown' ] ,
  md       => [ 'Text::Markdown' , 'markdown' ] ,
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

    my $content =  $module->new->$method( $self->content );
    return $self->replace_inline( $content );
  },
);

=attr converted_blurb

Converts the blurb portion to HTML

=cut

has converted_blurb => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  default => sub {
    my $self = shift;

    return $self->blurb
      unless exists $conversion_extension_map{ $self->ext };

    my( $module , $method ) =
      @{ $conversion_extension_map{ $self->ext }};
    load_class( $module );

    # Convert the blob
    my $blurb = $module->new->$method( $self->blurb );
    # Add the "read more" link
    $blurb .= q{<p class="readmore"><a href="} . $self->url . q{" class="readmore">read more</a></p>}
        if $self->blurb ne $self->content;

    return $self->replace_inline( $blurb );
  },
);



=attr hid

The HiD object for the current site. Here primarily to provide access to site
metadata.

=cut

has hid => (
  is  => 'ro' ,
  isa => 'HiD' ,
);


=attr layouts ( ro / HashRef[HiD::Layout] / required )

Hashref of layout objects keyed by name.

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

    my $layout_name = $self->get_metadata( 'layout' ) // $self->get_default_layout;

    my $layout = $self->layouts->{$layout_name} // $self->layouts->{default} //
      die "FIXME no default layout?";

    my $output = $layout->render( $self->template_data );

    return $output;
  }
);

=attr template_data

Data for passing to template processing function.

=cut

has template_data => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  lazy    => 1 ,
  default => sub {
    my $self = shift;

    my $data = {
      content  => $self->converted_content ,
      page     => $self->metadata ,
      site     => $self->hid ,
    };

    foreach my $method ( qw/ title url / ) {
      $data->{page}{$method} = $self->$method
        if $self->can( $method );
    }

    return $data;
  },
);

around BUILDARGS => sub {
  my $orig  = shift;
  my $class = shift;

  my %args = ( ref $_[0] and ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  unless ( $args{content} and $args{metadata} ) {
    open( my $IN , '<' , $args{input_filename} )
      or confess "$! $args{input_filename}";

    my $file_content;
    {
      local $/;
      $file_content .= <$IN>;
    }
    close( $IN );

    my( $metadata , $content );
    if ( $file_content =~ /^---/ ) {
      ( $metadata , $content ) = $file_content
        =~ /^---\n?(.*?)---\n?(.*)$/ms;
    }
    elsif ( $args{input_filename} =~ /\.html?$/ ) {
      die "plain HTML file without YAML front matter"
    }
    else {
      $content  = $file_content;
      $metadata = '';
    }

    $args{content}  = $content;
    $args{metadata} = Load( $metadata ) // {};
  }

  return $class->$orig( \%args );
};


=method replace_inline

Ability to replace placeholders surrounded by '##' with something else.

Useful to specify paths to media files.  In config:

replace_inline:
  MEDIA: /blog/media

=cut

sub replace_inline {
    my ($self,$rendered) = @_;

    my %config = %{ $self->config };

    if( exists $config{replace_inline} ) {
        foreach my $placeholder (keys %{ $config{replace_inline} }) {
            $rendered =~ s{##$placeholder##}{$config{replace_inline}->{$placeholder}}mg;
        }
    }
    return $rendered;
}

no Moose::Role;
1;
