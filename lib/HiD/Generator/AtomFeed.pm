# ABSTRACT: Atom feed generator

=head1 DESCRIPTION

This Generator produces an Atom feed of your posts.

Enable it by setting the 'atom_feed' key in your config to the path where the
feed should be generated.

The 'atom_feed_base' and 'atom_feed_link' keys, if they exist, will be used to
add the 'rel=alternate' base link and the 'rel=self' feed link to the atom
feed, respectively.

=cut

package HiD::Generator::AtomFeed;

use Moose;
with 'HiD::Generator';

use DateTime;
use HiD::VirtualPage;
use XML::Atom::Entry;
use XML::Atom::Feed;
use XML::Atom::Link;
use XML::Atom::Person;

has 'destination' => (
  is      => 'ro' ,
  isa     => 'HiD_DirPath' ,
);

=method generate

=cut

sub generate {
  my( $self , $site ) = @_;

  return unless
    my $destination = $site->config->{atom_feed};

  my $post_limit = $site->config->{atom_feed_posts} // 20;
  my $post_count = 1;

  my $feed = $self->_new_feed($site);

 POST: for my $post( @{ $site->posts }) {
    $feed->add_entry($self->_new_entry($post));

    $post_count++;
    last POST if $post_count > $post_limit;
  }

  my $feed_page = HiD::VirtualPage->new({
    output_filename => $site->destination . $destination ,
    content         => $feed->as_xml ,
  });

  $site->add_input( "ATOM FEED" => 'page' );
  $site->add_object( $feed_page );

  $site->INFO( "* Injected Atom feed");
}

sub _new_entry {
  my( $self , $post ) = @_;

  my $author = XML::Atom::Person->new();
  $author->name($post->author);

  my $link = XML::Atom::Link->new();
  $link->type('text/html');
  $link->rel('alternate');
  $link->href($post->url);

  my $entry = XML::Atom::Entry->new();
  $entry->title($post->title);
  $entry->author($author);
  $entry->add_link($link);
  $entry->content($post->converted_content);

  return $entry;
}

sub _new_feed {
  my( $self , $site ) = @_;

  my $feed = XML::Atom::Feed->new();
  my $title = $site->config->{atom_feed_title} // $site->config->{title};
  $feed->title( $title );

  if ( my $base_url = $site->config->{atom_feed_base} ) {
    my $base_link = XML::Atom::Link->new();
    $base_link->type('text/html');
    $base_link->rel('alternate');
    $base_link->href($base_url);

    $feed->add_link( $base_link );
  }

  if ( my $feed_url = $site->config->{atom_feed_link} ) {
    my $feed_link = XML::Atom::Link->new();
    $feed_link->type('application/atom+xml');
    $feed_link->rel('self');
    $feed_link->href( $feed_url );

    $feed->add_link( $feed_link );

    $feed->id( $feed_link );
  }

  $feed->updated(DateTime->now());

  return $feed;
}

__PACKAGE__->meta->make_immutable;
1;
