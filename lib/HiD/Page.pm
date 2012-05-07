package HiD::Page;
# ABSTRACT: Pages that are converted during the output process
use Moose;
with 'HiD::Role::IsConverted';
with 'HiD::Role::IsPublished';

use Path::Class     qw/ file / ;

=head1 NOTE

Also consumes L<HiD::Role::IsConverted> and L<HiD::Role::IsPublished>; see
documentation for that role as well if you're trying to figure out how an
object from this class works.

=method output_filename

=cut

sub output_filename {
  my $self = shift;

  return file( $self->dest_dir , $self->basename . '.html' )->stringify;
}

=method publish

=cut

sub publish {
  my $self = shift;

  $self->process(
    ### FIXME just ... gross.
    $self->layout->name . '.' . $self->layout->extension,
    $self->processing_data ,
    $self->output_filename ,
    ### FIXME also nasty...
  ) or die $self->hid->processor->tt->error;
}

__PACKAGE__->meta->make_immutable;
1;
