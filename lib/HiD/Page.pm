package HiD::Page;
use Mouse;
with 'HiD::Role::IsPublishable';
with 'HiD::Role::IsProcessed';

__PACKAGE__->meta->make_immutable;
1;
