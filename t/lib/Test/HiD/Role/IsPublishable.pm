use strict;
use warnings;

package Test::HiD::Role::IsPublishable;
use Test::Routine;
use Test::More;
use namespace::autoclean;

has test_object => (
  is      => 'ro' ,
  isa     => 'Object' ,
  builder => 'build_object_to_test' ,
);

test "has destination" => sub {
  my $test = shift;
  my $obj = $test->test_object;

  ok( $obj->destination );
};

test "can publish" => sub {
  my $test = shift;
  my $obj = $test->test_object;

  my $destination = $obj->destination;

  ok( ! -f $destination , "nothing at destination" );
  ok( $obj->publish     , "publish works" );
  ok( -f $destination   , "file at destination" );
};

1;
