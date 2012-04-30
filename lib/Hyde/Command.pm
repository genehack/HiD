package Hyde::Command;
# ABSTRACT: Base class for Hyde commands
use Mouse;
extends 'MouseX::App::Cmd::Command';

use Hyde;

has config_file => (
  is          => 'ro' ,
  isa         => 'Str' ,
  cmd_aliases => 'f' ,
  traits      => [ qw/ Getopt / ] ,
);

has hyde => (
  is       => 'ro' ,
  isa      => 'Hyde' ,
  lazy     => 1 ,
  init_arg => undef ,
  builder  => '_build_hyde' ,
  handles  => [
    'config' ,
  ] ,
);

sub _build_hyde { return Hyde->new }

__PACKAGE__->meta->make_immutable;
1;
