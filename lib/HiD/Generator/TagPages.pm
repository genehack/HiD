# ABSTRACT: Example generator to create tagged pages

=head1 DESCRIPTION

This is an example of a generator plugin. It generates one page per key in the
C<< $site->tags >> hash, and injects that page into the site so that it will
be published.

To activate this plugin, add a 'tags.generate' key to your config. You should
also add a 'tags.layout' key that provides a template file to use. Finally,
you may also set a 'tags.destination' key to indicate an output directory for
the tag files. If this is not set, it will default to the normal site-wise
destination.

=cut

package HiD::Generator::TagPages;

use Moose;
with 'HiD::Generator';

use HiD::Page;

=method generate

=cut

sub generate {
  my( $self , $site ) = @_;

  return unless $site->config->{tags}{generate};

  if ( exists $site->config->{tags}{input} ){
    $site->WARN("Using deprecated tags.input key. Please convert to tags.layout!" );
    $site->config->{tags}{layout} = $site->config->{tags}{input};
  }

  my $input_file = $site->config->{tags}{layout}
    or die "Must define tags.layout in config if tags.generate is enabled";

  my $destination = $site->config->{tags}{destination} // $site->destination;

  foreach my $tag ( keys %{ $site->tags } ) {
    my $page = HiD::Page->new({
      dest_dir       => $destination ,
      hid            => $site ,
      url            => "tags/$tag/" ,
      input_filename => $input_file ,
      layouts        => $site->layouts ,
    });
    $page->metadata->{tag} = $tag;

    $site->add_input( "Tag_$tag" => 'page' );
    $site->add_object( $page );

    $site->INFO( "* Injected tag page for '$tag'");
  }
}

__PACKAGE__->meta->make_immutable;
1;
