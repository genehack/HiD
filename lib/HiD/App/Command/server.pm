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
