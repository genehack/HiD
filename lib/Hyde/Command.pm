package Hyde::Command;
# ABSTRACT: Base class for Hyde commands
use Mouse;
extends 'MouseX::App::Cmd::Command';


__PACKAGE__->meta->make_immutable;
1;
