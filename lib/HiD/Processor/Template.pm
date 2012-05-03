package HiD::Processor::Template;
use Mouse;
extends 'HiD::Processor';

use Template;

has 'tt' => (
  is      => 'ro' ,
  isa     => 'Template' ,
  handles => [ qw/ process / ],
);

### FIXME fuuuuugly.
sub BUILDARGS {
  my $class = shift;

  my %args = ( ref $_[0] && ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  return { tt => Template->new( %args ) };
}
