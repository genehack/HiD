#! perl

use strict;
use warnings;

use File::Basename;
use File::Find::Rule;
use File::Path  qw/ remove_tree /;
use HiD;

use Test::File;
use Test::More;
use Test::Warn;


chdir 't/jekyll_test_source' or die $!;

remove_tree '_site' if -e -d '_site';

my $hid;
warning_like { $hid = HiD->new; $hid->config }
  qr/Could not read configuration/ ,
  'expected "no config" warning';

my $posts;
warnings_like { $posts = $hid->posts }
  qr/Skipping .* because 'published' flag is false/,
  'expected "skipping file b/c no publish" warning';

my $post_count = scalar @$posts;
is( $post_count , 28 , 'expected number of posts' );
# warning_is { $hid->publish } [] ,
#   'publish works and does not warn' ;
$hid->publish;

file_exists_ok( '_site/index.html' , 'see index file' );
file_contains_like(
  '_site/index.html' ,
  qr/$post_count Posts/ ,
  'see post count in index file',
);
my $last_post_content = $posts->[-1]->content;

file_contains_like(
  '_site/index.html' ,
  qr/$last_post_content/,
  'see last post content on index page',
);

my @files = File::Find::Rule->file->name('*.html')->in('_site/publish_test/2008/02/02');
is( scalar @files , 1 , 'only published one file from publis_test');
is( (basename $files[0]) , 'published.html' , 'and it is named published.html' );

my @post_dirs = File::Find::Rule->name('_posts')->in('_site');
is( scalar @post_dirs , 0 , 'no _posts in _site' );

file_exists_ok( '_site/about/index.html' );
file_exists_ok( '_site/contacts.html'    );
file_exists_ok( '_site/css/index.css'    );

done_testing;
