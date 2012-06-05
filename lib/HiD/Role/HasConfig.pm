# ABSTRACT: Role to be consumed by classes that are published during processing

=head1 SYNOPSIS

    package MyThingThatNeedsConfig;
    use Moose;
    with 'HiD::Role::HasConfig';

    ...

    1;

=head1 DESCRIPTION

This role provides access to the HiD Configuration when it's applied

=cut

package HiD::Role::HasConfig;
use Moose::Role;
use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

use File::Basename  qw/ fileparse /;
use HiD::Types;
use Path::Class     qw/ file /;
use Try::Tiny;
use YAML::XS           qw/ LoadFile /;

=attr config

Hashref of configuration information.

=method get_config

    my $config_key_value = $self->get_config( $config_key_name );

Given a config key name, returns a config key value.

=cut

has config => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  traits  => [ 'Hash' ],
  lazy    => 1 ,
  builder => '_build_config' ,
  handles => {
    get_config => 'get' ,
  }
);

sub _build_config {
  my $self = shift;

  my( $config , $config_loaded );

  if ( my $file = $self->config_file ) {
    try {
      $config = LoadFile( $file ) // {};
      ref $config eq 'HASH' or die $!;
      $config_loaded++;
    };
  }

  $config_loaded or $config = {}
    and warn "WARNING: Could not read configuration. Using defaults (and options).\n";

  my @cli_opts = ();
  push @cli_opts, %{ $self->cli_opts } if( $self->can('cli_opts') );

  return {
    %{ $self->default_config } ,
    %$config ,
    @cli_opts
  };
}

=attr config_file

Path to a configuration file.

=cut

has config_file => (
  is      => 'ro' ,
  isa     => 'Str' ,
  default     => '_config.yml' ,
);

=attr default_config

Hashref of standard configuration options. The default config is:

    destination => '_site'    ,
    include_dir => '_includes',
    layout_dir  => '_layouts' ,
    posts_dir   => '_posts' ,
    baseurl     => '/',
    source      => '.' ,

=cut

has default_config => (
  is       => 'ro' ,
  isa      => 'HashRef' ,
  traits   => [ 'Hash' ] ,
  init_arg => undef ,
  default  => sub{{
    destination => '_site'    ,
    include_dir => '_includes',
    layout_dir  => '_layouts' ,
    posts_dir   => '_posts' ,
    baseurl     => '/',
    source      => '.' ,
  }},
);

no Moose::Role;
1;
