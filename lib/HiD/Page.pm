package HiD::Page;
use Mouse;
with 'HiD::Role::IsPublishable';
with 'HiD::Role::IsProcessed';

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
