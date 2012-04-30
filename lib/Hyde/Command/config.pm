package Hyde::Command::config;
# ABSTRACT: dump configuration
use 5.010;
use Mouse;
extends 'Hyde::Command';

sub execute {
  my( $self , $opts , $args ) = @_;

  $args = [ 'config' ] unless $args->[0];

  use DDP;
  p $self->hyde->$_ foreach @$args;
}

__PACKAGE__->meta->make_immutable;
1;
