# ABSTRACT: Regular files that are only copied, not processed (e.g., CSS, JS, etc.)

=head1 SYNOPSIS

    my $file = HiD::File->new({
      dest_dir       => 'directory/for/output'
      input_filename => $file_filename ,
    });

=head1 DESCRIPTION

Object class representing "normal" files (ones that HiD just copies from
source to destination, without further processing).

=head1 NOTE

Also consumes L<HiD::Role::IsPublished>; see documentation for that role as
well if you're trying to figure out how an object from this class works.

=cut

package HiD::File;
use Moose;
with 'HiD::Role::IsPublished';
use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

use File::Basename  qw/ fileparse /;
use File::Copy      qw/ copy /;
use File::Path      qw/ make_path /;
use Path::Class     qw/ file / ;

=method publish

Publishes (in this case, copies) the input file to the output file.

=cut

sub publish {
  my $self = shift;

  my( undef , $dir ) = fileparse( $self->output_filename );

  make_path $dir unless -d $dir;

  copy( $self->input_filename , $self->output_filename ) or die $!;
}

# used to populate the 'url' attr in Role::IsPublished
sub _build_url {
  my $self = shift;

  return ( $self->basename eq 'index' )
    ? $self->input_path : $self->input_filename;
}

__PACKAGE__->meta->make_immutable;
1;
