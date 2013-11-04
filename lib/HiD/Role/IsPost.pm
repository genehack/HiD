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

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

use DateTime;
use Date::Parse    qw/ str2time  /;
use File::Basename qw/ fileparse /;
use HiD::Types;
use YAML::XS;

my $date_regex = qr|([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})|;

# override
sub _build_basename {
  my $self = shift;
  my $ext = '.' . $self->ext;
  my $basename = fileparse( $self->input_filename , $ext );
  $basename =~ s/^.*?$date_regex-// or die;
  return $basename;
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
        year  => $year ,
        month => $month ,
        day   => $day
      );
    }
  },
);

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

no Moose::Role;
1;
