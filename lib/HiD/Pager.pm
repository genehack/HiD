# ABSTRACT: Class for paging thru sets of entries

=head1 SYNOPSIS

  To use pagination with just the blog pages, set the following config
  options:

    pagination:
      entries: 10
      page: 'blog/%{page}s'
      template: 'blog/index.html'

  C<pagination.entries> sets the number of entries per
  page. C<pagination.page> sets the pattern for pages. C<pagination.template>
  is the template file that will be used for each file in turn. A
  C<index.html> will be appended to each page. Note that no 'page1' entry will
  be generated; in the example above, the first page would be at
  'blog/index.html', the second at 'blog/page2/index.html', and so on.

  If you need more control, or want to use pagination inside a
  L<HiD::Generator>, you can instatiate one like so:

    my $pager = HiD::Pager->new({
      entries             => $site->posts ,
      entries_per_page    => 5 ,
      hid                 => $site ,
      page_pattern        => 'blog/%{page}s' ,
    });

    while( my $page_data = $pager->next() ) {
      my $page = HiD::Page->new(
        metadata => { page_data => $page_data },
        # other page data here
      );
      # inject page into site, etc.
    }

    # in page template, assuming Kolon template syntax
    : for $page_data.posts -> $post {
    :   ## render page here
    : }

    : # other useful info for creating intra-page links and metadata
    : $page_data.current_page_url = url of current page
    : $page_data.page_number      = number of current page
    : $page_data.total_pages      = total number of pages
    : $page_data.prev_page        = number of previous page (undef if no previous)
    : $page_data.prev_page_url    = url of previous page (undef if no previous)
    : $page_data.next_page        = number of next page (undef if no next)
    : $page_data.next_page_url    = url of next page (undef if no next)

=head1 DESCRIPTION

Class providing pagination services for sets of posts. Can be used for main
blog post pages by setting up the appropriate configuration, or used inside a
C<HiD::Generator> class to provide paged sets of a subset of the posts on a
site.

=cut

package HiD::Pager;

use Moose;
# note: we also do 'with HiD::Role::DoesLogging', just later on because reasons.

use namespace::autoclean;

use 5.014;  # strict, unicode_strings
use utf8;
use autodie;
use warnings;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;

use Data::Page;
use String::Errf    qw/ errf /;

=attr entries

Array of L<HiD::Post> objects being worked with

=cut

has entries => (
  is       => 'ro',
  isa      => 'ArrayRef[HiD_Post]' ,
  traits   => [ qw/ Array / ] ,
  handles  => { total_entries => 'count' } ,
  required => 1 ,
);

=attr entries_per_page

Number of entries per page.

=cut

has entries_per_page => (
  is      => 'ro' ,
  isa     => 'HiD_PosInt' ,
  default => 10 ,
);

=attr hid

All hail the God Object.

=cut

has hid => (
  is       => 'ro' ,
  isa      => 'HiD' ,
  required => 1 ,
  handles  => [ qw/ get_config / ],
);
with 'HiD::Role::DoesLogging'; # needs to see the get_config delegation

=attr page_pattern

Regex used to generate per-page URLs

=cut

has page_pattern => (
  is      => 'ro',
  isa     => 'Str' ,
  default => 'blog/%{page}' ,
);

=attr pager

The L<Data::Page> object that does all the work.

=cut

has pager => (
  is      => 'ro' ,
  isa      => 'Data::Page' ,
  lazy     => 1,
  init_arg => undef ,
  builder  => '_build_pager' ,
  handles  => {
    page_number => 'current_page' ,
    next_page   => 'next_page' ,
    prev_page   => 'previous_page',
    splice      => 'splice',
    total_pages => 'last_page' ,
  }
);

sub _build_pager {
  my( $self ) = @_;

  my $pager = Data::Page->new();
  $pager->total_entries($self->total_entries);
  $pager->entries_per_page($self->entries_per_page);
  $pager->current_page(1);

  return $pager;
}

has _pager_page => (
  is      => 'rw' ,
  isa     => 'Maybe[Int]' ,
  lazy    => 1 ,
  default => sub { shift->pager->current_page },
);

=method current_page_url

Returns the URL for the current page in the set.

=cut

sub current_page_url {
  my $self = shift;
  return $self->_page_url( $self->page_number );
}

=method next

Returns the data structure for the pager information.

=cut

sub next {
  my( $self ) = @_;

  return undef unless defined $self->_pager_page;

  $self->page_number( $self->_pager_page );
  my @page_posts = $self->splice( reverse( $self->entries ));

  $self->_pager_page( $self->next_page );

  return {
    current_page_url => $self->current_page_url ,
    next_page        => $self->next_page ,
    next_page_url    => $self->next_page_url ,
    page_number      => $self->page_number ,
    posts            => \@page_posts,
    prev_page        => $self->prev_page ,
    prev_page_url    => $self->prev_page_url ,
    total_pages      => $self->total_pages ,
  };
}

=method next_page_url

Returns the URL for the next page in the set.

=cut

sub next_page_url {
  my $self = shift;
  if ( my $next = $self->next_page ){
    return $self->_page_url( $next );
  }
}

=method prev_page_url

Returns the URL for the previous page in the set.

=cut

sub prev_page_url {
  my $self = shift;
  if ( my $prev = $self->prev_page ){
    return $self->_page_url( $prev );
  }
}

sub _page_url {
  my( $self , $number ) = @_;

  confess('wtf') unless defined $number;

  $number = '' if $number == 1;

  my $url = errf $self->page_pattern , { page => $number };
  $url .= '/index.html' unless $url =~ /html$/;
  $url =~ s|//|/|g;

  return $url;
}

__PACKAGE__->meta->make_immutable;
