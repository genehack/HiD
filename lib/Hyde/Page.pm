package Hyde::Page;
use Mouse;

use Hyde::Types;

has filename => (
  is       => 'ro' ,
  isa      => 'Hyde::File' ,
  required => 1 ,
);

__PACKAGE__->meta->make_immutable;
1;
