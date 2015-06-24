# ABSTRACT: Role for blog posts

=head1 SYNOPSIS

    package HiD::ThingThatIsAPost;
    use Moose;
    with 'HiD::Role::IsPost';

    ...

    1;

=head1 DESCRIPTION

This role is consumed by objects that are blog posts and provides blog
post-specific attributes and methods.

=cut

package HiD::Role::IsPost;

use Moose::Role;
use namespace::autoclean;

use 5.014; # strict, unicode_strings
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;

use DateTime;
use Date::Parse    qw/ str2time  /;

use HiD::Types;

=attr author

=cut

has author => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => '_build_author' ,
);

sub _build_author {
  my $self = shift;

  my $author = $self->get_metadata( 'author' );
  return $author if defined $author;

  my $default_author = $self->get_config( 'default_author' );
  return $default_author if defined $default_author;

  die "Need author for " . $self->basename . "\n"
}

=attr categories

=cut

has categories => (
  is      => 'ro' ,
  isa     => 'ArrayRef' ,
  lazy    => 1 ,
  default => sub {
    my $self = shift;

    if ( my $category = $self->get_metadata( 'category' )) {
      return [ $category ];
    }
    elsif ( my $categories = $self->get_metadata( 'categories' )) {
      if ( ref $categories ) {
        return [ @$categories ];
      }
      else {
        my @categories = split /\s/ , $categories;
        return [ @categories ];
      }
    }
    else { return [] }
  },
);

=attr date

DateTime object for this post.

=cut

has date => (
  is      => 'ro' ,
  isa     => 'DateTime' ,
  lazy    => 1,
  handles => {
    day      => 'day' ,
    month    => 'month' ,
    strftime => 'strftime' ,
    year     => 'year' ,
  },
  default => sub {
    my $self = shift;

    if ( $self->get_config( 'publish_drafts' )){
      return DateTime->now if $self->is_draft;
    }

    my( $year , $month , $day );
    if ( my $date = $self->get_metadata( 'date' )) {
      return DateTime->from_epoch(
        epoch     => str2time( $date ),
        time_zone => 'local' ,
      );
    }
    else {
      ( $year , $month , $day ) = $self->input_filename
        =~ m|^.*?/([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})-|;
      return DateTime->new(
        year      => $year ,
        month     => $month ,
        day       => $day ,
        time_zone => 'UTC' ,
      );
    }
  },
);

=attr description

A one-line synopsis of the post (used, e.g., for metadata information used by Open Graph)

=cut

has description => (
  is      => 'ro' ,
  isa     => 'Maybe[Str]' ,
  lazy    => 1 ,
  builder => '_build_description' ,
);
sub _build_description { shift->get_metadata( 'description' ) }

=attr excerpt

It is generally useful to summarize or lead a post with a "read more" tag
added to the end of the post.  This is ideal for a blog where we might not
want to list the full post on the front page.

=cut

has excerpt => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  builder => '_build_excerpt',
);

sub _build_excerpt {
  my $self = shift;

  my $content = $self->content;

  return unless defined $content;

  my $sep = $self->hid->excerpt_separator;

  if($content =~ /^$sep/mp) {
    return ${^PREMATCH};
  }

  return $content;
}

=attr tags

=cut

has tags => (
  is      => 'ro' ,
  isa     => 'ArrayRef',
  traits  => [ qw/ Array / ] ,
  handles => { join_tags => 'join' } ,
  default => sub {
    my $self = shift;

    if ( my $tag = $self->get_metadata( 'tag' )) {
      return [ $tag ];
    }
    elsif ( my $tags = $self->get_metadata( 'tags' )) {
      if ( ref $tags ) {
        return [ @$tags ];
      }
      else {
        my @tags = split /\s/ , $tags;
        return [ @tags ];
      }
    }
    else { return [] }
  } ,
);

=attr title

=cut

has title => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => '_build_title' ,
);

sub _build_title {
  my $self = shift;

  my $title = $self->get_metadata( 'title' );

  return $self->basename unless defined $title;

  return ( ref $title ) ? $$title : $title;
}

=attr twitter_handles 

Returns an arrayref of the twitter handles passed via
the C<twitter> parameter.

=method has_twitter_handles

Returns c<true> if the post has any twitter handles associated with it, C<false>
otherwise.

=method all_twitter_handles

Returns the list of the twitter handles associated with the post.

=cut


has twitter_handles => (
  traits => [ 'Array' ],
  is => 'ro' ,
  isa => 'ArrayRef[Str]' ,
  lazy => 1 ,
  builder => '_build_twitter_handles' ,
  handles => {
      has_twitter_handles => 'count',
      all_twitter_handles => 'elements',
  },
);

sub _build_twitter_handles {
  my $self = shift;

  my $t = $self->get_metadata('twitter');

  return ref $t ? $t : [ $t ? $t : () ];
}

=method twitter

DEPRECATED: use <twitter_handles> instead.

Returns the first twitter handle given to C<twitter>.

=cut

sub twitter { 
    ($_[0]->all_twitter_handles)[0]
}




around BUILDARGS => sub {
  my $orig  = shift;
  my $class = shift;

  my %args = ( ref $_[0] and ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  if ( my $input = $args{input_filename} ) {
    if ( my $source = $args{source} ) {
      $input =~ s|$source/?||;
    }

    if ( my( $cat ) = $input =~ m|^(.+?)/?_posts/| ) {
      $args{categories} = [ split '/' , $cat ];
    }
  }

  return $class->$orig( \%args );
};

=method all_tags

Returns all tags for this post, joined together with commas

=cut

sub all_tags { shift->join_tags(',') }

=method is_draft

Returns a boolean value indicating whether this post is coming from the drafts
folder or not.

=cut

my $drafts_dir;
sub is_draft {
  my $self = shift;

  $drafts_dir //= $self->get_config( 'drafts_dir' );
  return ( $self->input_filename =~ /^$drafts_dir/ ) ? 1 : 0;
}

no Moose::Role;
1;
