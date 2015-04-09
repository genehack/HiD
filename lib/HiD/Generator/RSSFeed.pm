# ABSTRACT: RSS feed generator

=head1 DESCRIPTION

This Generator produces an RSS feed of your posts.

Enable it by setting the 'rss_feed.generate' key in your config to 1. Also
set an 'rss_feed.destination' key indicating where the feed should be
generated.

You may also set optional 'rss_feed.base' and 'rss_feed.link' keys to set
the 'rel=alternate' base link and the 'rel=self' link to the RSS feed,
respectively.

The 'rss_feed.title' config key can be used to give the feed a
title. Otherwise the site title will be used.

The 'rss_feed.posts' config key can be used to control the number of posts in
the feed. It defaults to 20.

=cut

package HiD::Generator::RSSFeed;

use Moose;
with 'HiD::Generator';

use 5.014; # strict, unicode_strings

use DateTime;
use XML::Feed;
use XML::Feed::Entry;

use HiD::VirtualPage;

=method generate

=cut

sub generate {
  my( $self , $site ) = @_;

  return unless $site->config->{rss_feed}{generate};

  my $destination = $site->config->{rss_feed}{destination};
  my $post_limit  = $site->config->{rss_feed}{posts} // 20;
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

  $site->add_input( "RSS FEED" => 'page' );
  $site->add_object( $feed_page );

  $site->INFO( "* Injected RSS feed");
}

sub _new_entry {
  my( $self , $post ) = @_;

  my $entry = XML::Feed::Entry->new('RSS');
  $entry->title($post->title);
  $entry->author($post->author);
  $entry->link($post->baseurl . $post->url);
  $entry->id($post->get_config('baseurl') . $post->url);
  $entry->issued($post->date);
  $entry->summary($post->description) if $post->description;
  $entry->content($post->converted_content);

  return $entry;
}

sub _new_feed {
  my( $self , $site ) = @_;

  my $feed  = XML::Feed->new('RSS');
  my $title = $site->config->{rss_feed}{title} // $site->config->{title};
  $feed->title( $title );

  $feed->base( $site->config->{rss_feed}{base} )
    if $site->config->{rss_feed}{base};

  if( $site->config->{rss_feed}{link}) {
    $feed->link( $site->config->{rss_feed}{link} );
    $feed->id( $site->config->{rss_feed}{link} );
  }

  $feed->modified(DateTime->now());

  return $feed;
}

__PACKAGE__->meta->make_immutable;
1;
