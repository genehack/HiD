# ABSTRACT: HiD type constraints

=head1 DESCRIPTION

Type constraints for HiD.

=cut

package HiD::Types;

use 5.014;
use utf8;
use strict;
use autodie;
use warnings;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

use Moose::Util::TypeConstraints;

subtype 'HiD_DirPath'
  => as 'Str'
  => where { -d $_ };

# TODO make this a bit more useful?
subtype 'HiD_FileExtension'
  => as 'Str' ,
  #=> where { what, exactly? }
  ;

subtype 'HiD_FilePath'
  => as 'Str'
  => where { -f $_ };

subtype 'HiD_PosInt'
  => as 'Int'
  => where { $_ > 0 }
  => message { "Must be positive integer." };

### FIXME delete if after 13 Nov 2014
class_type 'deprecated_HiD_Plugin_class' , { class => 'HiD::Plugin'};

role_type 'HiD_Plugin'    , { role => 'HiD::Plugin'};
role_type 'HiD_Generator' , { role => 'HiD::Generator'};

union 'Pluginish' , [qw/
                         deprecated_HiD_Plugin_class
                         HiD_Plugin
                         HiD_Generator
                       / ];

no Moose::Util::TypeConstraints;
1;
