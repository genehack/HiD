package HiD::Types;
use strict;

use Mouse::Util::TypeConstraints;

subtype 'HiD_DirPath'
  => as 'Str'
  => where { -d $_ };

# TODO make this a bit more useful?
subtype 'HiD_FileExtension'
  => as 'Str' ,
  ;

subtype 'HiD_FilePath'
  => as 'Str'
  => where { -f $_ };

no Mouse::Util::TypeConstraints;
1;
