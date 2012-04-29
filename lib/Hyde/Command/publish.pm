package Hyde::Command::publish;
use 5.010;
use Mouse;
extends 'Hyde::Command';

sub execute {
  my $self = shift;

  say "publish!";
}

__PACKAGE__->meta->make_immutable;
1;
