# ABSTRACT: Atom feed generator

=head1 DESCRIPTION

This Generator produces an Atom feed of your posts.

Enable it by setting the 'atom_feed.generate' key in your config to 1. Also
set an 'atom_feed.destination' key indicating where the feed should be
generated.

You may also set optional 'atom_feed.base' and 'atom_feed.link' keys to set
the 'rel=alternate' base link and the 'rel=self' link to the atom feed,
respectively.

The 'atom.title' config key can be used to give the feed a title. Otherwise
the site title will be used.

The 'atom.posts' config key can be used to control the number of posts in the
feed. It defaults to 20.

=head2 DEPRECATED CONFIG

This module formerly used different config keys. If this older configuration
is detected, a warning will be emitted and the configuration will be
internally upgraded to the new format. If you wish to silence this warning,
convert your config to use these new keys:

    OLD                   NEW
    atom_feed ----------> atom_feed.generate
                    *AND* atom_feed.destination
    atom_feed_base  ----> atom_feed.base
    atom_feed_link  ----> atom_feed.link
    atom_feed_posts ----> atom_feed.posts
    atom_feed_title ----> atom_feed.title

See the documentation above to understand what each key controls.

=cut

package HiD::Generator::AtomFeed;

use Moose;
with 'HiD::Generator';

use 5.014; # strict, unicode_strings

use DateTime;
use XML::Atom::Entry;
use XML::Atom::Feed;
use XML::Atom::Link;
use XML::Atom::Person;

use HiD::VirtualPage;

=method generate

=cut

sub generate {
  my( $self , $site ) = @_;

  if ( exists $site->config->{atom_feed} && ref $site->config->{atom_feed} ne 'HASH' ){
    $site->WARN( "Using deprecated atom_feed config! Please see docs on how to update!" );

    $site->config->{atom_feed} = _upgrade_atom_config( $site->config );
  }

  return unless $site->config->{atom_feed}{generate};

  my $destination = $site->config->{atom_feed}{destination};
  my $post_limit  = $site->config->{atom_feed}{posts} // 20;
  my $post_count  = 1;

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

  my $feed  = XML::Atom::Feed->new();
  my $title = $site->config->{atom_feed}{title} // $site->config->{title};
  $feed->title( $title );

  if ( my $base_url = $site->config->{atom_feed}{base} ) {
    my $base_link = XML::Atom::Link->new();
    $base_link->type('text/html');
    $base_link->rel('alternate');
    $base_link->href($base_url);

    $feed->add_link( $base_link );
  }

  if ( my $feed_url = $site->config->{atom_feed}{link} ) {
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


sub _upgrade_atom_config {
  my( $old_config ) = @_;

  my $new_config = {
    generate    => 1 ,
    destination => $old_config->{atom_feed}
  };

  foreach (qw/ base link posts title /) {
    if ( exists $old_config->{"atom_feed_$_"} ) {
      $new_config->{$_} = $old_config->{"atom_feed_$_"}
    };
  }

  return $new_config;
}

__PACKAGE__->meta->make_immutable;
1;
