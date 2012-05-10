package HiD::App;
# ABSTRACT: Static website generation system
use Moose;
extends 'MooseX::App::Cmd';
use namespace::autoclean;

=head1 SYNOPSIS

See C<perldoc hid> for usage information.

=cut

sub default_command { 'publish' };

__PACKAGE__->meta->make_immutable;
1;
