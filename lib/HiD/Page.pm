package HiD::Page;
use Mouse;
with 'HiD::Role::IsProcessed';

use namespace::autoclean;

use HiD::Types;

use YAML::XS qw/ Load /;

__PACKAGE__->meta->make_immutable;
1;
