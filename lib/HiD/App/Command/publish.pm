package HiD::App::Command::publish;
# ABSTRACT: HiD 'publish' sub-command
use 5.010;
use Moose;
extends 'HiD::App::Command';

=attr limit_posts

=cut

has limit_posts => (
  is          => 'ro' ,
  isa         => 'Int' ,
  cmd_aliases => 'l' ,
  traits      => [ 'Getopt' ] ,
);

sub _run {
  my( $self , $opts , $args ) = @_;

  my $config = {};
  if ( $self->limit_posts ) {
    $config->{limit_posts} = $self->limit_posts;
  }

  $self->publish;
}

__PACKAGE__->meta->make_immutable;
1;
