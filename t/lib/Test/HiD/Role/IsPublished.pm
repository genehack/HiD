use strict;
use warnings;

package Test::HiD::Role::IsPublished;
use Test::Routine;
use Test::More;
use namespace::autoclean;

has expected_basename => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

has expected_dir => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

has expected_suffix => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

has expected_url => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

test "parsing input filename into parts" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  is( $subject->basename   , $test->expected_basename , 'expected basename');
  is( $subject->ext        , $test->expected_suffix   , 'expected ext');
  is( $subject->input_path , $test->expected_dir      , 'expected dir');
};

test "has url" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  is( $subject->url , $test->expected_url , 'expected url' );
};

1;
