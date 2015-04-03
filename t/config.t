#! perl

use strict;
use warnings;

use lib 't/lib';

use Test::More;
use Test::Warn;
use Test::HiD::Util qw/ write_bad_config write_config /;

use Path::Tiny;

use HiD;

my $test_dir = Path::Tiny->tempdir();
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

{
  write_config( {} );

  my $hid = HiD->new({ config_file => '_config.yml' });

  my $config;
  warning_is { $config = $hid->config } undef ,
    'no warning with config file';

  is_deeply( $config , $hid->default_config , 'default config' );
}

{
  write_config( { destination => '_new_site' } );

  my $hid = HiD->new({ config_file => '_config.yml' });

  my $config;
  warning_is { $config = $hid->config } undef ,
    'no warning with config file';

  my $expected_config = $hid->default_config;
  $expected_config->{destination} = '_new_site';

  is_deeply( $config , $expected_config , 'expected config' );
}

{ # override config file from CLI
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

{
  write_bad_config( '--dusted' );

  # and now we get the warning again.
  my $hid = HiD->new({ config_file => '_config.yml' });

  my $config;
  warning_like { $config = $hid->config }
    qr|Could not read configuration\. Using defaults \(and options\)\.| ,
      'fire warning with bad config file';

  is_deeply( $config , $hid->default_config , 'default config' );
}

chdir('/');
done_testing();
