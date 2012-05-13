package HiD::App::Command;
# ABSTRACT: Base class for HiD commands
use Moose;
extends 'MooseX::App::Cmd::Command';

use HiD;

has config_file => (
  is          => 'ro' ,
  isa         => 'Str' ,
  cmd_aliases => 'f' ,
  traits      => [ qw/ Getopt / ] ,
  default     => '_config.yml' ,
);

has hid => (
  is       => 'ro' ,
  isa      => 'HiD' ,
  traits   => [ qw/ NoGetopt/ ] ,
  init_arg => undef ,
  writer   => '_set_hid' ,
  handles  => [
    'all_objects' ,
    'config' ,
    'destination' ,
    'publish' ,
  ] ,
);

sub _build_hid { return HiD->new }

sub execute {
  my( $self , $opts , $args ) = @_;

  if ( $opts->{help_flag} ) {
    print $self->usage->text;
    exit;
  }

  $self->_set_hid( HiD->new({
    cli_opts    => $opts ,
    config_file => $self->config_file ,
  }));

  $self->_run( $opts , $args );
}

__PACKAGE__->meta->make_immutable;
1;
