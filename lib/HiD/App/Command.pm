package HiD::App::Command;
# ABSTRACT: Base class for HiD commands
use Mouse;
extends 'MouseX::App::Cmd::Command';

use HiD;

has config_file => (
  is          => 'ro' ,
  isa         => 'Str' ,
  cmd_aliases => 'f' ,
  traits      => [ qw/ Getopt / ] ,
);

has hid => (
  is       => 'ro' ,
  isa      => 'HiD' ,
  traits   => [ qw/ NoGetopt/ ] ,
  lazy     => 1 ,
  init_arg => undef ,
  builder  => '_build_hid' ,
  handles  => [
    'all_objects' ,
    'config' ,
    'destination' ,
  ] ,
);

sub _build_hid { return HiD->new }

sub execute {
  my( $self , $opts , $args ) = @_;

  if ( $opts->{help_flag} ) {
    print $self->usage->text;
    exit;
  }

  $self->_run( $opts , $args );
}

__PACKAGE__->meta->make_immutable;
1;
