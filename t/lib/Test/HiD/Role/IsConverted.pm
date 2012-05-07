use strict;
use warnings;

package Test::HiD::Role::IsConverted;
use Test::Routine;
use Test::More;
use namespace::autoclean;

has converted_content => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1,
  default => sub { shift->subject->content } ,
);

test "has converted content" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  is( $subject->converted_content , $test->converted_content );
};

test "has metadata" => sub { ok(1) };

test "has permalink" => sub { ok(1) };

test "has template data" => sub { ok(1) };

1;
