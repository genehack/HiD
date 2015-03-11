# ABSTRACT: Generator for category pages

=head1 DESCRIPTION

This is an example of a generator plugin. It generates one page per key in the
C<< $site->categories >> hash, and injects that page into the site so that it will
be published.

This plugin can be used with minimal work on your part by enabling the
required options in your configuration and putting a file like the following
example into the C<_plugins> directory of your site:

    package Categories;
    use Moose;
    extends 'HiD::Generator::CategoryPages';

    # you override the default destination like so
    has '+destination' => ( default => '_site/subdir' );

    __PACKAGE__->meta->make_immutable;
    1;

As shown above, you can control where the resulting pages are generated by
overridding the C<destination> attribute. If you want to tweak more than that,
you're probably better off just copying the whole module into your C<_plugins>
directory and modifying it directly.

=cut

package HiD::Generator::CategoryPages;

use Moose;
with 'HiD::Generator';

use HiD::Page;

has 'destination' => (
  is      => 'ro' ,
  isa     => 'HiD_DirPath' ,
);

=method generate

=cut

sub generate {
  my( $self , $site ) = @_;

  return unless $site->config->{categories}{generate};

  my $input_file = $site->config->{categories}{layout}
    or die "Must define categories.layout in config if categories.generate is enabled";

  my $destination = $self->destination // $site->destination;

  $self->_create_destination_directory_if_needed( $destination );

  foreach my $category ( keys %{ $site->categories } ) {
    my $page = HiD::Page->new({
      dest_dir => $destination ,
      hid      => $site ,
      url      => "category/$category/" ,
      input_filename => $input_file ,
      layouts  => $site->layouts ,
    });
    $page->metadata->{category} = $category;
    $page->metadata->{posts} = $site->categories->{$category};

    $site->add_input( "Category_$category" => 'page' );
    $site->add_object( $page );

    $site->INFO( "* Injected tag page for '$category'");
  }
}

__PACKAGE__->meta->make_immutable;
1;
