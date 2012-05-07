package Test::HiD::File;
use Moose;
with 'Test::HiD::Role::IsPublishable';

use namespace::autoclean;

use File::Temp qw/ tempfile tempdir /;
use HiD;
use HiD::File;

sub build_object_to_test {
  my( undef , $name ) = tempfile();
  my $tempdir = tempdir();

  return HiD::File->new({
    filename => $name,
    hid      => HiD->new({
      destination => $tempdir,
    }),
  });
}

1;
