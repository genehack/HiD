package Hyde::Types;
use strict;

use Mouse::Util::TypeConstraints;

subtype 'Hyde::Dir'
  => as 'Str'
  => where { -d $_ };

subtype 'Hyde::File'
  => as 'Str'
  => where { -f $_ };

no Mouse::Util::TypeConstraints;
1;
