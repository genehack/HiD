package Test::HiD::File;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use Test::File;
use namespace::autoclean;

use Path::Tiny;

use HiD::File;

has subject => (
  is  => 'ro' ,
  isa => 'HiD::File' ,
);

test "output filename" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  # FIXME really, this should be masking the input directory off input
  # filename and the output directory off output file name...
  my $input  = path($subject->input_filename)->basename;
  my $output = path($subject->output_filename)->basename;

  like( $output , qr/\Q$input\E$/ , 'output ends like input');
};

test "publish" => sub {
  my $test    = shift;
  my $subject = $test->subject;

  my $output = $subject->output_filename;

  file_not_exists_ok( $output , 'no output yet' );
  $subject->publish;
  file_exists_ok( $output , 'and now output' );
};


1;
