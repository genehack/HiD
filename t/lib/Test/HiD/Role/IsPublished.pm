use strict;
use warnings;

package Test::HiD::Role::IsPublished;
use Test::Routine;
use Test::More;
use namespace::autoclean;

has expected_url => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

test "parsing input filename into parts" => sub {
  my $test = shift;
  my $subject = $test->subject;
  my @parts = split '/' , $subject->input_filename;
  my $file = pop @parts;
  my $dir  = join '/' , @parts;
  my( $base , $ext ) = $file =~ /^(.*?)\.([^.]+)$/;
  is( $subject->basename   , $base   , 'expected basename');
  is( $subject->ext        , $ext    , 'expected ext');
  is( $subject->input_path , "$dir/" , 'expected dir');
};

test "has url" => sub {
  my $test = shift;
  my $subject = $test->subject;
  my $url = $subject->url;
  like( $url , qr|^/|, 'starts with /' );
};

1;
