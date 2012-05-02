package HiD::Types;
use strict;

use Mouse::Util::TypeConstraints;

subtype 'HiD::Dir'
  => as 'Str'
  => where { -d $_ };

subtype 'HiD::File'
  => as 'Str'
  => where { -f $_ };

no Mouse::Util::TypeConstraints;
1;
