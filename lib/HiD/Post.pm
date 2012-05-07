package HiD::Post;
use Moose;
with 'HiD::Role::IsConverted';
with 'HiD::Role::IsPost';
with 'HiD::Role::IsPublished';

use String::Errf qw/ errf /;

### FIXME
sub output_filename {}

# override
sub _build_layout {
  my $self = shift;

  my $layout_name = $self->get_metadata( 'layout' ) // 'post';

  return $self->get_layout_by_name( $layout_name );
}

# override
sub _build_permalink {
  my $self = shift;

  my %formats = (
    date   => '/%{categories}s/%{year}s/%{month}s/%{day}s/%{title}s.html' ,
    pretty => '/%{categories}s/%{year}s/%{month}s/%{day}s/%{title}s/' ,
    none   => '/%{categories}s/%{title}s.html' ,
  );

  my $permalink_format = $self->get_metadata( 'permalink' ) //
    $self->hid->config->{permalink} // 'date';

  $permalink_format = $formats{$permalink_format}
    if exists $formats{$permalink_format};

  my $categories = join '/' , @{ $self->categories } || '';
  my $day        = $self->strftime( '%d' , $self->day   );
  my $month      = $self->strftime( '%m' , $self->month );

  return errf $permalink_format , {
    categories => $categories ,
    day        => $day ,
    i_day      => $self->day,
    i_month    => $self->month,
    month      => $month ,
    title      => $self->filename_title ,
    year       => $self->year ,
  };
}

sub publish {
  my $self = shift;

  my $content;
  my $data = $self->processing_data;

  $self->process(
    \$self->content ,
    $data ,
    \$content,
  ) or die $self->hid->processor->tt->error;

  $data->{content} = $content;

  $self->process(
    ### FIXME just ... gross.
    $self->layout->name . '.' . $self->layout->extension,
    $data ,
    $self->output_filename ,
    ### FIXME also nasty...
  ) or die $self->hid->processor->tt->error;
}

__PACKAGE__->meta->make_immutable;
1;
