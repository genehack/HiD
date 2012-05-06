package HiD::App;
# ABSTRACT: Static website generation system
use Mouse;
extends 'MouseX::App::Cmd';
use namespace::autoclean;

=head1 SYNOPSIS

See C<perldoc hid> for usage information.

=cut


__PACKAGE__->meta->make_immutable;
1;
