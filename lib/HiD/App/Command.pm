# ABSTRACT: Base class for HiD commands

=head1 SYNOPSIS

    package HiD::App::Command::my_awesome_command;
    use Moose;
    extends 'HiD::App::Command';

    sub _run {
      my( $self , $opts , $args ) = @_;

      # do whatcha like
    }

    1;

=head1 DESCRIPTION

Base class for implementing subcommands for L<hid>. Provides basic attributes
like C<--config_file>. If you're going to write a sub-command, you want to
base it on this class.

=cut

package HiD::App::Command;
use Moose;
extends 'MooseX::App::Cmd::Command';
use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

use HiD;

=attr config_file

Path to config file.

Defaults to './_config.yml'

=cut

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
