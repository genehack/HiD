# ABSTRACT: HiD 'server' subcmd - start up a Plack-based web server for your site

=head1 SYNOPSIS

    $ ../bin/hid server
    HTTP::Server::PSGI: Accepting connections at http://0:5000/

=head1 DESCRIPTION

Start a Plack-based web server that serves your C<destination> directory.

=head1 SEE ALSO

See L<HiD::App::Command> for additional command line options supported by all
sub commands.

=cut

package HiD::App::Command::server;
use Moose;
extends 'HiD::App::Command::publish';
with 'HiD::Role::PublishesDrafts';
use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

use namespace::autoclean;

use Class::Load      qw/ :all /;
use Plack::Builder;
use Plack::Runner;

=attr auto_refresh

Automatically refresh result when source file/dir changed, just likey jekyll

=cut

has auto_refresh => (
  is            => 'ro',
  isa           => 'Bool',
  traits        => [ 'Getopt' ],
  cmd_aliases   => [ qw/ auto A / ],
  documentation => 'auto re-publish when source changes, Default=False',
  lazy          => 1,
  default       => 0,
);

=attr clean

Remove any existing site directory prior to the publication run

=cut

has clean => (
  is          => 'ro' ,
  isa         => 'Bool' ,
  cmd_aliases => 'C' ,
  traits      => [ 'Getopt' ] ,
);

=attr debug

Emit debug-style logging for requests

=cut

has debug => (
  is          => 'ro' ,
  isa         => 'Bool' ,
  cmd_aliases => 'D' ,
  traits      => [ 'Getopt' ] ,
);

=attr port

Port number to bind. Defaults to 5000.

=cut

has port => (
  is            => 'ro' ,
  isa           => 'Int' ,
  traits        => [ 'Getopt' ] ,
  cmd_aliases   => 'p' ,
  documentation => 'port to run the server on. Default=5000' ,
  lazy          => 1 ,
  builder       => '_build_port' ,
);

sub _build_port {
  my $self = shift;

  return $self->{port} if defined $self->{port};

  my $config = $self->config;
  return $self->config->{server_port} // 5000;
}

sub _run {
  my( $self , $opts , $args ) = @_;

  my $config = $self->config;
  if ( $self->clean ) {
    $config->{clean_destination} = 1;
  }

  if ( $self->publish_drafts ){
    $config->{publish_drafts} = 1;
  }

  $self->publish;

  my $app = HiD::Server->new( root => $self->destination )->to_app;

  my %args = ( -p => $self->port );

  # auto refresh
  if ( $self->auto_refresh ) {
    my @dirs = map { $self->hid->get_config($_) } qw/ include_dir layout_dir posts_dir /;

    for my $dir (qw/pages regular_files/) {
      push @dirs, map { $_->input_filename } @{ $self->hid->$dir };
    }

    $args{'-R'} = join ',', @dirs;
    $args{'-r'} = 1;

    my $original_app = $app;
    $app = \sub {
      say 'Rebuild ... ';
      $self->publish;
      $original_app;
    };
  }

  if ( $self->debug ) {
    if ( try_load_class( 'Plack::Middleware::DebugLogging' )) {
      $app = builder {
        enable_if { $ENV{PLACK_ENV} eq 'development' } 'DebugLogging';
        $app;
      };
    }
    else {
      print STDERR "*** Plack::Middleware::DebugLogging required for debug logging.\n";
      print STDERR "*** Continuing with normal logging.\n";
    }
  }

  my $runner = Plack::Runner->new;
  $runner->parse_options(%args);
  $runner->run($app);
}

__PACKAGE__->meta->make_immutable;

package # hide...
  HiD::Server;

use parent 'Plack::App::File';

sub locate_file  {
  my ($self, $env) = @_;

  my $path = $env->{PATH_INFO} || '';

  $path =~ s|^/|| unless $path eq '/';

  if ( -e -d $path and $path !~ m|/$| ) {
    $path .= '/';
    $env->{PATH_INFO} .= '/';
  }

  $env->{PATH_INFO} .= 'index.html'
    if ( $path && $path =~ m|/$| );

  return $self->SUPER::locate_file( $env );
}

1;
