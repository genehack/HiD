#ABSTRACT: Logging role

package HiD::Role::DoesLogging;
use Moose::Role;

use Log::Log4perl;

requires 'get_config';

=attr logger_config

Configuration for logging. Defaults to:

  log4perl.logger                                   = DEBUG, Screen
  log4perl.appender.Screen                          = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.layout                   = PatternLayout
  log4perl.appender.Screen.layout.ConversionPattern = [%d] %5p %m%n

=cut

has logger_config => (
  is      => 'ro' ,
  isa     => 'HashRef',
  lazy    => 1 ,
  default => sub {
    my $self = shift;
    my $config = $self->get_config('logger_config');

    return $config
      if ( $config && %$config );

    return {
      'log4perl.logger'                                   => 'WARN, Screen' ,
      'log4perl.appender.Screen'         => 'Log::Log4perl::Appender::Screen',
      'log4perl.appender.Screen.layout'                   => 'PatternLayout' ,
      'log4perl.appender.Screen.layout.ConversionPattern' => '[%d] %5p %m%n' ,
    };
  },
);

=attr logger

Log4perl object for logging. Handles:

=over

=item * DEBUG

=item * WARN

=item * INFO

=item * ERROR

=item * FATAL

=back

=cut

has logger => (
  is      => 'ro' ,
  isa     => 'Log::Log4perl::Logger',
  lazy    => 1 ,
  builder => '_build_logger' ,
  handles  => {
    DEBUG => 'debug' ,
    WARN  => 'warn'  ,
    INFO  => 'info'  ,
    ERROR => 'error' ,
    FATAL => 'fatal' ,
    LOGWARN => 'logwarn' ,
  },
);

sub _build_logger {
  my $self = shift;

  Log::Log4perl->init( $self->logger_config );
  Log::Log4perl->get_logger();
}

no Moose::Role;
1;
