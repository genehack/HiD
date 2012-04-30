package Hyde::Types;
use strict;

use Mouse::Util::TypeConstraints;

subtype 'File'
  => as 'Str'
  => where { -f $_ };

no Mouse::Util::TypeConstraints;
1;
