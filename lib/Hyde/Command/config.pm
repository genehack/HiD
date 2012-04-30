package Hyde::Command::config;
# ABSTRACT: dump configuration
use 5.010;
use Mouse;
extends 'Hyde::Command';

sub execute {
  my( $self , $opts , $args ) = @_;

  my $subsubcmd = $args->[0] // 'config';

  use DDP;
  p $self->hyde->$subsubcmd;
}

__PACKAGE__->meta->make_immutable;
1;
