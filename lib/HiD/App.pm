# ABSTRACT: Static website generation system

=head1 SYNOPSIS

See C<perldoc hid> for usage information.

=cut

package HiD::App;
use Moose;
extends 'MooseX::App::Cmd';
with 'HiD::Role::HasConfig';
use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

sub default_command { 'publish' };

__PACKAGE__->meta->make_immutable;
1;
