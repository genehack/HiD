package HiD::App::Command::server;
# ABSTRACT: HiD 'server' subcmd - start up a Plack-based web server for your site
use Moose;
extends 'HiD::App::Command';

use 5.010;

use Plack::Runner;

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

  $self->publish;

  my $app = HiD::Server->new( root => $self->destination )->to_app;

  my $runner = Plack::Runner->new();
  $runner->parse_options( '-p' , $self->port );
  $runner->run($app);
}

__PACKAGE__->meta->make_immutable;

package # hide...
  HiD::Server;

use parent 'Plack::App::File';

sub locate_file  {
  my ($self, $env) = @_;

  my $path = $env->{PATH_INFO} || '';

  $env->{PATH_INFO} .= 'index.html'
    if ( $path && $path =~ m|/$| );

  return $self->SUPER::locate_file( $env );
}

1;
