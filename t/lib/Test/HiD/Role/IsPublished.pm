use strict;
use warnings;

package Test::HiD::Role::IsPublished;
use Test::Routine;
use Test::More;
use namespace::autoclean;

test "has basename" => sub {
  my $test = shift;
  my $subject = $test->subject;
  my @parts = split '/' , $subject->input_filename;
  my $file = $parts[-1];
  my( $base ) = $file =~ /^(.*?)\.[^.]+$/;
  is( $subject->basename , $base , 'expected basename');
};

test "has ext" => sub {
  my $test = shift;
  my $subject = $test->subject;
  my @parts = split '/' , $subject->input_filename;
  my $file = $parts[-1];
  my( $ext ) = $file =~ /^.*?\.([^.]+)$/;
  is( $subject->ext , $ext , 'expected extension');
};

test "has url" => sub {
  my $test = shift;
  my $subject = $test->subject;
  my $url = $subject->url;
  like( $url , qr|^/|, 'starts with /' );
};

1;
