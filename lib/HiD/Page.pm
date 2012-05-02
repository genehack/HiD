package HiD::Page;
use Mouse;

use HiD::Types;

has filename => (
  is       => 'ro' ,
  isa      => 'HiD::File' ,
  required => 1 ,
);

__PACKAGE__->meta->make_immutable;
1;
