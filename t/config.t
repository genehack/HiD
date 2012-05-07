#! perl

use strict;
use warnings;

use Test::More;
use Test::Warn;

use autodie;
use Cwd;
use File::Temp  qw/ tempfile tempdir /;
use YAML::XS    qw/ DumpFile /;

use HiD;

my $start_dir = cwd;
my $test_dir  = tempdir( CLEANUP => 1 );

chdir $test_dir or BAIL_OUT "Couldn't change to test dir";

{
  my $hid = HiD->new({});

  my $config;
  warning_like { $config = $hid->config }
    qr|^WARNING: Could not read configuration\. Using defaults \(and options\)\.| ,
      'fire warning with no config file';
  is_deeply( $config , {} , 'empty config' );
}
{
  my $hid = HiD->new({ config_file => 'nosuchfile' });

  my $config;
  warning_like { $config = $hid->config }
    qr|^WARNING: Could not read configuration\. Using defaults \(and options\)\.| ,
    'fire warning with nonexistant config file';
  is_deeply( $config , {} , 'empty config' );
}

# write out empty config file
DumpFile( '_config.yml' , {} );

{
  my $hid = HiD->new({});

  my $config;
  warning_is { $config = $hid->config } undef ,
    'no warning with config file';
  is_deeply( $config , {} , 'empty config' );
}

# write out config file with option
DumpFile( '_config.yml' , { destination => '_new_site' } );

{
  my $hid = HiD->new({});

  my $config;
  warning_is { $config = $hid->config } undef ,
    'no warning with config file';
  is_deeply( $config , { destination => '_new_site' } , 'expected config' );
}

# write out a bad config file
open( my $fh , '>' , '_config.yml' );
print $fh '--dusted';
close( $fh );

{
  # and now we get the warning again.
  my $hid = HiD->new({ config_file => 'nosuchfile' });

  my $config;
  warning_like { $config = $hid->config }
    qr|^WARNING: Could not read configuration\. Using defaults \(and options\)\.| ,
      'fire warning with bad config file';
  is_deeply( $config , {} , 'empty config' );
}

# there's no place like home.
chdir $start_dir;
done_testing;
