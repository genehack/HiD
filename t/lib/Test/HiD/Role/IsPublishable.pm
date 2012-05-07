use strict;
use warnings;

package Test::HiD::Role::IsPublishable;
use Test::Routine;
use Test::More;
use namespace::autoclean;

has page => (
  is      => 'ro' ,
  isa     => 'Object' ,
  builder => 'build_page' ,
);

test "has destination" => sub {
  my $test = shift;
  my $page = $test->page;

  ok( $page->destination );
};

test "can publish" => sub {
  my $test = shift;
  my $page = $test->page;

  my $destination = $page->destination;

  ok( ! -f $destination , "nothing at destination" );
  ok( $page->publish    , "publish works" );
  ok( -f $destination   , "file at destination" );
};

1;
