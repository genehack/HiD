use strict;
use warnings;

package Test::HiD::Role::IsConverted;
use Test::Routine;
use Test::More;
use namespace::autoclean;

has converted_content_regexp => (
  is       => 'ro' ,
  isa      => 'RegexpRef' ,
  required => 1 ,
);

has rendered_content_regexp => (
  is       => 'ro' ,
  isa      => 'RegexpRef' ,
  required => 1 ,
);

test "has converted content" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  like( $subject->converted_content , $test->converted_content_regexp );
};

test "has metadata" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  my $metadata = $subject->metadata;
  is( ref $metadata , 'HASH' );

  ok( exists $metadata->{title}  );
};

test "has rendered content" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  like( $subject->rendered_content , $test->rendered_content_regexp );
};

test "has template data" => sub { ok(1) };

1;
