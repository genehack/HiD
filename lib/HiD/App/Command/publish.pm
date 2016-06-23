# ABSTRACT: publish site

=head1 SYNOPSIS

    $ hid publish

    # publish directly to GitHub Pages
    $ hid publish --to_github_pages
    $ hid publist -G

=head1 DESCRIPTION

Processes files according to the active configuration and writes output files
accordingly.

=head1 SEE ALSO

See L<HiD::App::Command> for additional command line options supported by all
sub commands.

=cut

package HiD::App::Command::publish;

use Moose;
extends 'HiD::App::Command';
with 'HiD::Role::PublishesDrafts';
with 'HiD::Role::DoesLogging';
use namespace::autoclean;

use 5.014; # strict, unicode_strings
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;

use Class::Load  qw/ try_load_class /;
use File::Copy   qw/ move /;
use Path::Tiny;

=attr clean

Remove any existing site directory prior to the publication run

=cut

has clean => (
  is          => 'ro' ,
  isa         => 'Bool' ,
  cmd_aliases => 'C' ,
  traits      => [ 'Getopt' ] ,
);

=attr limit_posts

Limit the number of blog posts that will be written out. If you have a large
number of blog posts that haven't changed, setting this can significantly
speed up the publication process.

=cut

has limit_posts => (
  is          => 'ro' ,
  isa         => 'Int' ,
  cmd_aliases => 'l' ,
  traits      => [ 'Getopt' ] ,
);

=attr to_github_pages

If this option is set, the publishing process will switch to a 'gh-pages'
branch in the current repository. If such a branch does not exist, a new
"orphan" branch of that name will be created. Publication will happen in the
normal destination directory, and then files will be moved into the root level
of the repo and the destination directory removed. At the end of publication,
all pending changes will be committed and a push (specifically, 'git push -u')
will be done. Finally, the repository will be set back to whatever branch had
been checked out before.

If this option is given and the current working directory is not the root
level of a Git repository, an error will be thrown.

=cut

has to_github_pages => (
  is          => 'ro' ,
  isa         => 'Bool' ,
  cmd_aliases => 'G' ,
  traits      => [ 'Getopt' ]
);

=attr verbose

Be noisy. Primarily useful for debugging issues publishing to GitHub.

=cut

has verbose => (
  is          => 'ro' ,
  isa         => 'Bool' ,
  cmd_aliases => 'v' ,
  traits      => [ 'Getopt' ] ,
  default     => 0 ,
);

# internal attributes

has gw => (
  is      => 'ro' ,
  isa     => 'Git::Wrapper' ,
  lazy    => 1 ,
  builder => '_build_gw' ,
  traits  => [ 'NoGetopt' ] ,
  handles => [ qw/
                   add
                   branch
                   checkout
                   commit
                   push
                   rev_parse
                   status
  / ] ,
);

sub _build_gw { Git::Wrapper->new('.') }

has saved_branch => (
  is     => 'rw' ,
  isa    => 'Str' ,
  writer => 'set_saved_branch' ,
  traits => [ 'NoGetopt' ] ,
);

sub _run {
  my( $self , $opts , $args ) = @_;

  my $config = $self->config;
  if ( $self->clean ) {
    $config->{clean_destination} = 1;
  }

  if ( $self->limit_posts ) {
    $config->{limit_posts} = $self->limit_posts;
  }

  if ( $self->publish_drafts ){
    $config->{publish_drafts} = 1;
  }

  if ( $self->to_github_pages ) {
    say( "PUBLISHING TO gh-pages BRANCH" ) if $self->verbose;

    $self->FATAL( "Not in the root level of a Git repo" )
      unless -e -d '.git';

    $self->FATAL( "Git::Wrapper is required for the '--to-github-pages' option" )
      unless try_load_class( 'Git::Wrapper' );

    # publish into a tempdir...
    $config->{destination} = Path::Tiny->tempdir->stringify();
    say( "*** destination set to $config->{destination}" ) if $self->verbose;
  }

  $self->publish();

  if ( $self->to_github_pages ) {

    say( "Storing current branch" ) if $self->verbose;
    $self->set_saved_branch( $self->get_current_branch() );

    say( "Switching to gh_pages branch (creating if needed)" ) if $self->verbose;
    $self->_create_gh_pages_if_needed_and_switch_branch();

    # move stuff out of destination (which is a tempdir at this point,
    # remember) into the current dir
    say( "Moving published files to current directory" ) if $self->verbose;
    my $d = path( $self->config->{destination} );
    ## use File::Copy::move b/c Path::Tiny::move is mud spelled backwards
    move( $_ , './' ) foreach ( $d->children() );

    # add everything, commit, and push
    if ( $self->status->is_dirty() ) {
      say( "Committing files and pushing" ) if $self->verbose;

      $self->add( '.' );
      ### FIXME include the date or something.
      ### or have a '--message/-m' option and some sensible default
      $self->commit( "-m" => "Published to GitHub pages by HiD!" );
      $self->push( '-u' );
    }
    else {
      say( "No changes to commit." ) if $self->verbose;
    }

    # and go back to the starting branch
    say( "Restoring previous branch" ) if $self->verbose;
    $self->checkout( $self->saved_branch );
  }
}

sub _create_gh_pages_if_needed_and_switch_branch {
  my $self = shift;

  # do we already have 'gh-pages' ?
  ## 'branch' output is either '* NAME' or '  NAME', so strip that
  ### FIXME can we require 5.20 and then switch to s///r ?
  if ( grep { $_ eq 'gh-pages' } map { s/\*?  ?// ; $_ } $self->branch() ) {
    say( "* Checking out existing gh-pages branch" ) if $self->verbose;
    $self->checkout( 'gh-pages' )
      unless $self->_get_current_branch eq 'gh-pages';

    return 1;
  }

  # otherwise, let's set it up
  say( '* Creating gh-pages branch' ) if $self->verbose;

  # make the orphan branch
  $self->checkout( '--orphan' => 'gh-pages' );

  # clean out all files already there
  say( '* Cleaning out existing files' ) if $self->verbose;
  foreach ( path('.')->children() ) {
    # skip over .git*
    next if /^.git/;

    $_->is_dir() ? $_->remove_tree() : $_->remove()
  }

  # and we're good to go
  return 1;
}

=method get_config

Required for logging output, can be ignored by end users.

=cut

# this is required by DoesLogging -- but having an empty hash for it works
# just as well.
sub get_config { {} }

sub _get_current_branch { shift->rev_parse( '--abbrev-ref' => 'HEAD' ) }

__PACKAGE__->meta->make_immutable;
1;
