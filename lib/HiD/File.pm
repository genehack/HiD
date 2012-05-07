package HiD::File;
# ABSTRACT: Regular files that are only copied, not processed (e.g., CSS, JS, etc.)
use Mouse;
with 'HiD::Role::IsPublished';

use File::Basename  qw/ fileparse /;
use File::Copy      qw/ copy /;
use File::Path      qw/ make_path /;
use Path::Class     qw/ file / ;

=head1 NOTE

Also consumes L<HiD::Role::IsPublished>; see documentation for that role as
well if you're trying to figure out how an object from this class works.

=method output_filename

Returns the path to the file that will be created when this object's C<write>
method is called.

=cut

sub output_filename {
  my $self = shift;

  return file( $self->dest_dir , $self->input_filename )->stringify;
}

=method publish

Publishes (in this case, copies) the input file to the output file.

=cut

sub publish {
  my $self = shift;

  my( undef , $dir ) = fileparse( $self->output_filename );

  make_path $dir unless -d $dir;

  copy( $self->input_filename , $self->output_filename ) or die $!;
}


__PACKAGE__->meta->make_immutable;
1;
