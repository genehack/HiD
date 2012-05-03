package HiD::Command::publish;
use 5.010;
use Mouse;
extends 'HiD::Command';

sub execute {
  my $self = shift;

  _publish_pages( $self );
}

sub _publish_pages {
  my $self = shift;

  my @pages = @{ $self->hid->pages };

  foreach my $page ( @pages ) {

    my $layout = $page->layout->name;

    $self->hid->process(
      ### FIXME just ... gross.
      $page->layout->name . '.' . $page->layout->extension,
      $page->processing_data ,
      $page->filename ,
      ### FIXME also nasty...
    ) or die $self->hid->processor->tt->error;
  }
}

__PACKAGE__->meta->make_immutable;
1;
