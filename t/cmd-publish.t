#! perl

use strict;
use warnings;

use App::Cmd::Tester;
use Test::File;
use Test::File::Contents;
use Test::More;

use autodie;
use Cwd;
use File::Temp  qw/ tempfile tempdir /;
use YAML        qw/ DumpFile /;

use HiD::App;

my $start_dir = cwd;
my $test_dir  = tempdir();

chdir $test_dir or BAIL_OUT "Couldn't change to test dir";

diag "Testing in $test_dir";

mkdir "_$_" foreach qw/ includes layouts posts site /;
{
  open( my $fh , '>' , '_layouts/default.html' );
  print $fh <<'EOHTML';
<html><head><title>{{page.title}}</title></head><body>{{{content}}}</body></html>
EOHTML
  close( $fh );
}
{
  open( my $fh , '>' , '_layouts/post.html' );
  print $fh 'POST: {{{content}}}';
  close( $fh );
}

{ # running publish without anything there and no config should still work,
  # albeit with a warning
  my $result = test_app( 'HiD::App' => [ 'publish' ]);

  is   $result->stdout    , '' , 'expected STDOUT';
  is   $result->exit_code , 0  , 'exit=success';

  like $result->stderr ,
    qr/Could not read configuration/ ,
    'warning on STDERR';
}
{    # running without a command name should do the same
  my $result = test_app( 'HiD::App' => [ ]);

  is   $result->stdout    , '' , 'expected STDOUT';
  is   $result->exit_code , 0  , 'exit=success';

  like $result->stderr ,
    qr/Could not read configuration/ ,
      'warning on STDERR';
}

DumpFile( '_config.yml' , {
  source        => '.' ,
  logger_config => {
    'log4perl.logger'                                   => 'FATAL, Screen' ,
    'log4perl.appender.Screen'         => 'Log::Log4perl::Appender::Screen',
    'log4perl.appender.Screen.layout'                   => 'PatternLayout' ,
    'log4perl.appender.Screen.layout.ConversionPattern' => '[%d] %5p %m%n' ,
  } ,
} );

{ # as should publish once there is a config
  _assert_good_run();
}

{ # publish with a regular file should copy that file to _site
  open( my $fh , '>' , 'test.css' );
  print $fh 'this is some fake css';
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/test.css' , 'file copied' );
  files_eq_or_diff( 'test.css' , '_site/test.css' , 'file copied without changes' );
}
{ # publish with a regular file in a dir should copy that whole structure
  mkdir 'css';
  open( my $fh , '>' , 'css/test.css' );
  print $fh 'this is some fake css';
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/css/test.css' , 'file copied' );
  files_eq_or_diff( 'css/test.css' , '_site/css/test.css' , 'file copied without changes' );
}
{ # publish with a file in _site that doesn't correspond to an input file =
  # that file gets removed

  open( my $fh , '>' , '_site/dummy_file' );

  _assert_good_run();

  file_not_exists_ok( '_site/dummy_file' );
}
{ # publish with 'page' file = file is processed into output dir
  open( my $fh , '>' , 'index.markdown' );
  print $fh <<EOL;
---
title: foo
---
# this should be h1
EOL
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/index.html' , 'expected file' );
  file_contains_like(
    '_site/index.html' , qr|<h1>this should be h1</h1>| , 'expected content'
  );
}
{ # publish with 'page' file = HTML is processed into output dir
  open( my $fh , '>' , 'plain.html' );
  print $fh <<'EOL';
---
layout: default
title: plain html
---
<h1>this should be h1</h1>
{{title}}
EOL
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/plain.html' , 'expected file' );
  file_contains_like(
    '_site/plain.html' , qr|<h1>this should be h1</h1>| , 'expected content'
  );
  file_contains_like(
    '_site/plain.html' , qr|plain html| , 'more expected content'
  );
}
{ # 'page' file without YAML front matter = still process
  open( my $fh , '>' , 'no_yaml.mkdn' );
  print $fh <<EOL;
# this will not stay as YAML
EOL
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/no_yaml.html' , 'expected file' );
  file_contains_like(
    '_site/no_yaml.html' , qr|<h1>this will not stay as YAML</h1>| , 'expected content'
  );
}
{ # 'page' file with permalink
  open( my $fh , '>' , 'page_permalink.mkdn' );
  print $fh <<'EOL';
---
permalink: /permalink_page/index.html
---
content.
{{page.url}}
EOL
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/permalink_page/index.html' , 'expected file' );
  file_contains_like(
    '_site/permalink_page/index.html' , qr|permalink_page/| , 'expected content'
  );
}
{ # 'post' file processing
  open( my $fh , '>' , '_posts/2012-05-06-test.mkdn' );
  print $fh <<'EOL';
---
layout: post
title: this is a test post
---
this is a test post, and it's called {{page.title}}
and it lives at {{page.url}}
EOL
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/2012/05/06/test.html' , 'expected post file');
  file_contains_like(
    '_site/2012/05/06/test.html' ,
    qr|POST: <p>this is a test post, and it's called this is a test post| ,
    'expected content'
  );
  file_contains_like(
    '_site/2012/05/06/test.html' ,
    qr|and it lives at /2012/05/06/test.html</p>| ,
    'expected content'
  );
}
{ # 'post' file processing with "pretty" style permalinks
  open( my $fh , '>' , '_posts/2012-05-06-pretty.mkdn' );
  print $fh <<'EOL';
---
layout: post
permalink: pretty
title: this is a test post
---
this is a test post, and it's called {{page.title}}

and it lives at {{page.url}}
EOL
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/2012/05/06/pretty/index.html' , 'expected post file');
  file_contains_like(
    '_site/2012/05/06/pretty/index.html' ,
    qr|POST: <p>this is a test post, and it's called this is a test post| ,
    'expected content'
  );
  file_contains_like(
    '_site/2012/05/06/pretty/index.html' ,
    qr|and it lives at /2012/05/06/pretty/</p>| ,
    'expected content'
  );
}
{ # 'post' file without layout still defaults to 'post' layout
  open( my $fh , '>' , '_posts/2012-05-06-post.mkdn' );
  print $fh <<'EOL';
---
title: this is a test post
---
this is a test post, and it's called {{page.title}}
EOL
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/2012/05/06/post.html' , 'expected post file');
  file_contains_like(
    '_site/2012/05/06/post.html' ,
    qr|POST: <p>this is a test post, and it's called this is a test post</p>| ,
    'expected content'
  );
}
{ # 'post' file with default layout gets default layout
  open( my $fh , '>' , '_posts/2012-05-06-default.mkdn' );
  print $fh <<'EOL';
---
layout: default
title: this is a test post
---
this is a test post, and it's called {{page.title}}
EOL
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/2012/05/06/default.html' , 'expected post file');
  file_contains_like(
    '_site/2012/05/06/default.html' ,
    qr|this is a test post, and it's called this is a test post| ,
    'expected content'
  );
  file_contains_like(
    '_site/2012/05/06/default.html' ,
    qr|<title>this is a test post</title>| ,
    'expected content'
  );
}
{ # 'post' file can override date in yaml
  open( my $fh , '>' , '_posts/2012-05-06-date-override.mkdn' );
  print $fh <<'EOL';
---
date: 1999-01-01
title: this is a test post
---
this is a test post, and it's called {{page.title}}
and it was made on {{page.date}}
EOL
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/1999/01/01/date-override.html' , 'expected post file');
  file_contains_like(
    '_site/1999/01/01/date-override.html' ,
    qr|and it was made on 1999-01-01| ,
    'expected content'
  );
}

TODO: { # embedded layouts
  local $TODO = 'embedded layouts all fucked up';

  {
    open( my $fh , '>' , '_layouts/embedded_post.html' );
    print $fh <<'EOL';
---
layout: default
----
EMBEDDED POST: {{content}}
EOL
    close( $fh );
  }

  open( my $fh , '>' , '_posts/2012-05-06-embedded_layout.mkdn' );
  print $fh <<'EOL';
---
layout: embedded_post
title: this is a test post
---
this is a test embedded post, and it's called {{page.title}}
EOL
  close( $fh );

  _assert_good_run();

  file_exists_ok( '_site/2012/05/06/embedded_layout.html' , 'expected post file');
  file_contains_like(
    '_site/2012/05/06/embedded_layout.html' ,
    qr|EMBEDDED POST: this is a embedded test post, and it's called this is a test post| ,
    'expected content'
  );
}



## tests to write
# setting 'processor' in config (use '+$MODULE' to bypass wrapper, etc.)
# setting 'destination' in config
# setting 'permalink' in config (and then still overriding in specific post)
# setting fully custom permalink format
# permalink with categories

# there's no place like home.
chdir $start_dir;
done_testing;

sub _assert_good_run {
  my $result = test_app( 'HiD::App' => [ 'publish' ]);

  is $result->stdout    , '' , 'expected STDOUT';
  is $result->stderr    , '' , 'empty STDERR';
  is $result->exit_code , 0  , 'exit=success';
}
