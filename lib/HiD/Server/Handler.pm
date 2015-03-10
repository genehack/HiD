package HiD::Server::Handler;
use strict;
use warnings;

use parent 'Plack::Handler::Standalone';

sub new {
  my( $class , %args ) = @_;

  my $hid = delete $args{hid};

  die "I must be passed a HiD not a $hid!"
    unless defined $hid and $hid->can('publish');

  my $self = $class->SUPER::new(%args);

  $self->{__hid__} = $hid;

  return $self;

}

sub republish {
  my $self = shift;

  my $hid = $self->{__hid__};

  $hid->reset_hid();

  # FIXME eeeeevvvviillll
  $hid->config();  # force builder to fire
  $hid->{hid}{config}{clean_destination} = 1; # get up in them guts

  $hid->publish();
}

1;
