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
    qr|Could not read configuration\. Using defaults \(and options\)\.| ,
      'fire warning with no config file';
  is_deeply( $config , $hid->default_config , 'default config' );
}
{
  my $hid = HiD->new({ config_file => 'nosuchfile' });

  my $config;
  warning_like { $config = $hid->config }
    qr|Could not read configuration\. Using defaults \(and options\)\.| ,
    'fire warning with nonexistant config file';
  is_deeply( $config , $hid->default_config , 'default config' );
}

# write out empty config file
DumpFile( '_config.yml' , {} );

{
  my $hid = HiD->new({ config_file => '_config.yml' });

  my $config;
  warning_is { $config = $hid->config } undef ,
    'no warning with config file';
  is_deeply( $config , $hid->default_config , 'default config' );
}

# write out config file with option
DumpFile( '_config.yml' , { destination => '_new_site' } );

{
  my $hid = HiD->new({ config_file => '_config.yml' });

  my $config;
  warning_is { $config = $hid->config } undef ,
    'no warning with config file';
  my $expected_config = $hid->default_config;
  $expected_config->{destination} = '_new_site';
  is_deeply( $config , $expected_config , 'expected config' );
}

# override config file from CLI
{
  my $hid = HiD->new({
    cli_opts    => { destination => 'override' } ,
    config_file => '_config.yml' ,
  });

  my $config;
  warning_is { $config = $hid->config } undef ,
    'no warning with config file'; # b/c previous file still there
  my $expected_config = $hid->default_config;
  $expected_config->{destination} = 'override';
  is_deeply( $config , $expected_config , 'expected config' );
}

# write out a bad config file
open( my $fh , '>' , '_config.yml' );
print $fh '--dusted';
close( $fh );

{
  # and now we get the warning again.
  my $hid = HiD->new({ config_file => '_config.yml' });

  my $config;
  warning_like { $config = $hid->config }
    qr|Could not read configuration\. Using defaults \(and options\)\.| ,
      'fire warning with bad config file';
  is_deeply( $config , $hid->default_config , 'default config' );
}

# there's no place like home.
unlink '_config.yml';
chdir $start_dir;
done_testing;
