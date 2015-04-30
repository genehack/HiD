# ABSTRACT: dump configuration

=head1 SYNOPSIS

    $ hid config
    \ {
        destination   "_site",
        include_dir   "_includes",
        layout_dir   "_layouts",
        posts_dir   "_posts",
        source   "."
    }
    $ hid config pages
    [ massive output elided ]

=head1 DESCRIPTION

Dumps the active configuration (using L<Data::Printer>)

If given an argument, will dump the corresponding attribute from the active
L<HiD> instance. This can be useful when debugging, because it allows you to
see precisely what data structures are being built.

=head1 SEE ALSO

See L<HiD::App::Command> for additional command line options supported by all
sub commands.

=cut

package HiD::App::Command::config;

use Moose;
extends 'HiD::App::Command';
use namespace::autoclean;

use 5.014;  # strict, unicode_strings
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;

use Data::Printer;

sub _run {
  my( $self , $opts , $args ) = @_;

  $args = [ 'config' ] unless $args->[0];

  my $out;
  $out .= p $self->hid->$_ foreach @$args;

  print $out;
}

__PACKAGE__->meta->make_immutable;
1;
