package Test::HiD::RegularFile;
use Moose;
with 'Test::HiD::Role::IsPublishable';

use namespace::autoclean;

use File::Temp qw/ tempfile tempdir /;
use HiD;
use HiD::RegularFile;

sub build_object_to_test {
  my( undef , $name ) = tempfile();
  my $tempdir = tempdir();

  return HiD::RegularFile->new({
    filename => $name,
    hid      => HiD->new({
      site_dir => $tempdir,
    }),
  });
}

1;
