package Test::HiD::RegularFile;
use Moose;
with 'Test::HiD::Role::IsPublishable';

use namespace::autoclean;

use File::Temp qw/ tempfile tempdir /;
use HiD::Config;
use HiD::RegularFile;

sub build_object_to_test {
  my( undef , $name ) = tempfile();
  my $tempdir = tempdir();

  return HiD::RegularFile->new({
    filename => $name,
    hid      => HiD::Config->new({
      site_dir => $tempdir,
    }),
  });
}

1;
