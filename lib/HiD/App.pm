# ABSTRACT: Static website generation system

=head1 SYNOPSIS

See C<perldoc hid> for usage information.

=cut

package HiD::App;

use Moose;
extends 'MooseX::App::Cmd';
use namespace::autoclean;

use 5.014;  # strict, unicode_strings
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;

sub default_command { 'help' };

__PACKAGE__->meta->make_immutable;
1;
