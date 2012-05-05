package HiD::RegularFile;
use Mouse;
with 'HiD::Role::IsPublishable';

use File::Basename  qw/ fileparse /;
use File::Copy      qw/ copy /;
use File::Path      qw/ make_path /;

sub publish {
  my $self = shift;

  my( undef , $dir ) = fileparse( $self->destination );
  make_path $dir unless -d $dir;

  copy( $self->filename , $self->destination ) or die $!;

  return 1;
}


__PACKAGE__->meta->make_immutable;
1;
