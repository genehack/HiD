package HiD::Post;
use Mouse;
with 'HiD::Role::IsPublishable';
with 'HiD::Role::IsProcessed';
with 'HiD::Role::IsPost';

use String::Errf qw/ errf /;

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

  unless ( $permalink_format =~ /%\{.*?\}/ ) {
    if ( exists $formats{$permalink_format} ) {
      $permalink_format = $formats{$permalink_format};
    }
  }

  my $categories = join '/' , @{ $self->categories } || '';
  my $day        = $self->strftime( '%d' , $self->day   ),
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


__PACKAGE__->meta->make_immutable;
1;
