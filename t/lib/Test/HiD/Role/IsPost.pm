use strict;
use warnings;

package Test::HiD::Role::IsPost;
use Test::Routine;
use Test::More;
use namespace::autoclean;

use Date::Parse qw/ str2time /;
use DateTime;

has expected_categories => (
  is       => 'ro' ,
  isa      => 'ArrayRef' ,
  required =>  1,
);

has expected_date => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

has expected_title => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

test "categories" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  is_deeply( $subject->categories , $test->expected_categories );
};

test "correct date" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  my $dt = DateTime->from_epoch(
    epoch     => str2time( $test->expected_date ),
    time_zone => 'local',
  );

  is( 0 , DateTime->compare( $subject->date , $dt ));
};

test "tags" => sub {
 TODO: {
    local $TODO = 'write tag tests';
    ok(0);
  }
};

test "title" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  is( $subject->title , $test->expected_title );
};

1;
