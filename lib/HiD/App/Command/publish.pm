# ABSTRACT: publish site

=head1 SYNOPSIS

    $ hid publish

    $ hid  # 'publish' is the default command...

=head1 DESCRIPTION

Processes files according to the active configuration and writes output files
accordingly.

=head1 SEE ALSO

See L<HiD::App::Command> for additional command line options supported by all
sub commands.

=cut

package HiD::App::Command::publish;
use Moose;
extends 'HiD::App::Command';
use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

=attr limit_posts

Limit the number of blog posts that will be written out. If you have a large
number of blog posts that haven't changed, setting this can significantly
speed up the publication process.

=cut

has limit_posts => (
  is          => 'ro' ,
  isa         => 'Int' ,
  cmd_aliases => 'l' ,
  traits      => [ 'Getopt' ] ,
);

sub _run {
  my( $self , $opts , $args ) = @_;

  my $config = {};
  if ( $self->limit_posts ) {
    $config->{limit_posts} = $self->limit_posts;
  }

  $self->publish;
}

__PACKAGE__->meta->make_immutable;
1;
