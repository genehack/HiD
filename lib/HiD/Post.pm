package HiD::Post;
use Moose;
with 'HiD::Role::IsConverted';
with 'HiD::Role::IsPost';
with 'HiD::Role::IsPublished';

use File::Basename  qw/ fileparse /;
use File::Path      qw/ make_path /;
use String::Errf    qw/ errf /;

=method get_default_layout

=cut

sub get_default_layout { 'post' }

# override
sub _build_url {
  my $self = shift;

  my %formats = (
    date   => '%{categories}s/%{year}s/%{month}s/%{day}s/%{title}s.html' ,
    pretty => '%{categories}s/%{year}s/%{month}s/%{day}s/%{title}s/' ,
    none   => '%{categories}s/%{title}s.html' ,
  );

  ### FIXME need a way to get overall config in here...
  my $permalink_format = $self->get_metadata( 'permalink' ) // 'date';

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
    title      => $self->basename ,
    year       => $self->year ,
  };
}

sub publish {
  my $self = shift;

  my( undef , $dir ) = fileparse( $self->output_filename );

  make_path $dir unless -d $dir;

  open( my $out , '>' , $self->output_filename ) or die $!;
  print $out $self->rendered_content;
  close( $out );
}

__PACKAGE__->meta->make_immutable;
1;
