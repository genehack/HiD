package HiD::Processor::Template;
use Mouse;
extends 'HiD::Processor';

use Template;

has 'tt' => (
  is      => 'ro' ,
  isa     => 'Template' ,
  handles => [ qw/ process / ],
);
