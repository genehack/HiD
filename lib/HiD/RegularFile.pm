package HiD::RegularFile;
use Mouse;
use namespace::autoclean;

use HiD::Types;

has destination => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

has filename => (
  is       => 'ro' ,
  isa      => 'HiD_FilePath' ,
  required => 1 ,
);

sub BUILDARGS {
  my $class = shift;

  my %args = ( ref $_[0] && ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  die "filename required for page"
    unless $args{filename};

  die "site required for page"
    unless $args{site};

  $args{destination} = join '/' , $args{site} , $args{filename};

  return \%args;
}

__PACKAGE__->meta->make_immutable;
1;
