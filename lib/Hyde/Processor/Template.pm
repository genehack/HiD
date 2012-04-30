package Hyde::Processor::Template;
use Mouse;
extends 'Hyde::Processor';

use Template;

has 'tt' => (
  is      => 'ro' ,
  isa     => 'Template' ,
  handles => [ qw/ process / ],
);
