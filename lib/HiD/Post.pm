package HiD::Post;
use Mouse;
with 'HiD::Role::IsPost';

use namespace::autoclean;

use DateTime;
use HiD::Types;
use YAML::XS;


__PACKAGE__->meta->make_immutable;
1;
