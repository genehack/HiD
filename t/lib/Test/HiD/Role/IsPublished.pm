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
  if ( $base =~ m|[0-9]{4}-[0-9]{2}-[0-9]{2}-| ) {
    $base =~ s|[0-9]{4}-[0-9]{2}-[0-9]{2}-||;
  }
  is( $subject->basename   , $base   , 'expected basename');
  is( $subject->ext        , $ext    , 'expected ext');
  is( $subject->input_path , "$dir/" , 'expected dir');
};

test "has url" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  is( $subject->url , $test->expected_url , 'expected url' );
};

1;
