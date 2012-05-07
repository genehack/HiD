use strict;
use warnings;

package Test::HiD::Layout;
use Test::Routine;
use Test::More;
use Test::File;
use namespace::autoclean;

has expected_output_regex => (
  is       => 'ro' ,
  isa      => 'RegexpRef' ,
  required => 1 ,
);

has subject => (
  is       => 'ro' ,
  isa      => 'HiD::Layout' ,
  required => 1 ,
);

has test_content => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

test "render" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  my $output = $subject->render({
    content => $test->test_content ,
  });

  like( $output , $test->expected_output_regex );
};

1;
