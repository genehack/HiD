package HiD::RegularFile;
use Mouse;
with 'HiD::Role::IsPublishable';

use namespace::autoclean;

use HiD::Types;

__PACKAGE__->meta->make_immutable;
1;
