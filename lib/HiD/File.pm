package HiD::File;
# ABSTRACT: Regular files that are only copied, not processed (e.g., CSS, JS, etc.)
use Moose;
with 'HiD::Role::IsPublished';

use File::Basename  qw/ fileparse /;
use File::Copy      qw/ copy /;
use File::Path      qw/ make_path /;
use Path::Class     qw/ file / ;

=head1 NOTE

Also consumes L<HiD::Role::IsPublished>; see documentation for that role as
well if you're trying to figure out how an object from this class works.

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

  return ( $self->input_filename =~ m|/index.html$| )
    ? $self->input_path : $self->input_filename;
}

__PACKAGE__->meta->make_immutable;
1;
