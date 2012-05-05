package HiD::Command;
# ABSTRACT: Base class for HiD commands
use Mouse;
extends 'MouseX::App::Cmd::Command';

use HiD::Config;

has config_file => (
  is          => 'ro' ,
  isa         => 'Str' ,
  cmd_aliases => 'f' ,
  traits      => [ qw/ Getopt / ] ,
);

has hid => (
  is       => 'ro' ,
  isa      => 'HiD::Config' ,
  traits   => [ qw/ NoGetopt/ ] ,
  lazy     => 1 ,
  init_arg => undef ,
  builder  => '_build_hid' ,
  handles  => [
    'all_objects' ,
    'config' ,
    'site_dir' ,
  ] ,
);

sub _build_hid { return HiD::Config->new }

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
