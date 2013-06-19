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
extends 'HiD::App::Command';
use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

use namespace::autoclean;

use Plack::Runner;
use AnyEvent::Filesys::Notify;

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

=attr auto_refresh

Automatically refresh result when source file/dir changed, just likey jekyll

=cut

has auto_refresh => (
    is          => 'ro',
    isa         => 'Bool',
    traits      => ['Getopt'],
    cmd_aliases => 'auto',
    lazy        => 1,
    default     => 0,
);
sub _run {
  my( $self , $opts , $args ) = @_;

  $self->publish;

  my $app = HiD::Server->new( root => $self->destination )->to_app;

  # auto refresh
  if ( $self->auto_refresh ) {
      my @dirs;

      # posts, include and layout
      for my $dir (qw/posts_dir include_dir layout_dir/) {
           push @dirs, $self->hid->get_config($dir);
      }

      # regular_files and pages
      for my $dir (qw/pages regular_files/) {
          push @dirs, map { $_->input_filename } @{ $self->hid->$dir };
      }

      say "*** auto refresh, watching at:";
      say foreach @dirs;
      say "***";
      my $building = 0;
      AnyEvent::Filesys::Notify->new(
          dirs => \@dirs,
          interval => 1.0,
          filter => sub { shift !~ /\.(swap|#|~)$/ },
          backend => $^O eq 'darwin' ? 'KQueue' : '', # Mac::FSEvents do not support watch at file
          cb => sub {
              return if $building;
              $building = 1;
              say 'Rebuilding ... ';
              $self->_set_hid( HiD->new({
                  cli_opts => $self->hid->cli_opts,
                  config_file => $self->hid->config_file,
              }));
              $self->publish;
              $building = 0;
          }
      );
      eval "use Twiggy; 1" or
          die "You should install Twiggy when use --auto_refresh option.";
  }

  my $runner = Plack::Runner->new;
  $runner->parse_options( -p => $self->port );
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
