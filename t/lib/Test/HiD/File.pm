use strict;
use warnings;

package Test::HiD::File;
use Test::Routine;
use Test::More;
use Test::File;
use namespace::autoclean;

use File::Temp qw/ tempfile tempdir /;
use HiD::File;

has subject => (
  is  => 'ro' ,
  isa => 'HiD::File' ,
);

test "output filename" => sub {
  my $test = shift;
  my $subject = $test->subject;

  my $input  = $subject->input_filename;
  my $output = $subject->output_filename;
  like( $output , qr/$input$/ , 'output ends like input');
};

test "publish" => sub {
  my $test = shift;
  my $subject = $test->subject;

  my $output = $subject->output_filename;

  file_not_exists_ok( $output , 'no output yet' );
  $subject->publish;
  file_exists_ok( $output , 'and now output' );
};


1;
