package HiD::Role::IsPost;
use Mouse::Role;
with 'HiD::Role::IsProcessed';

use DateTime;
use HiD::Types;
use String::Errf qw/ errf /;
use YAML::XS;

=attr categories

=cut

### TODO parse categories out of metadat
has categories => (
  is      => 'ro' ,
  isa     => 'ArrayRef' ,
  default => sub {[]} ,
);

=attr date

=cut

has date => (
  is      => 'ro' ,
  isa     => 'DateTime' ,
  lazy    => 1,
  builder => '_build_date' ,
  handles => {
    day      => 'day' ,
    month    => 'month' ,
    strftime => 'strftime' ,
    year     => 'year' ,
  },
);

sub _build_date {
  my $self = shift;

  ### FIXME configurable?
  my $date_regex = qr|([0-9]{4})-([0-9]{2})-([0-9]{2})|;

  my( $year , $month , $day , $title , $ext ) = $self->filename
    =~ m|^_posts/$date_regex-(.*?)\.([^.]+)$|;

  $self->_set_filename_ext( $ext )     if $ext;
  $self->_set_filename_title( $title ) if $title;

  if ( my $date = $self->get_metadata( 'date' )) {
    ( $year , $month , $day ) = $date
      =~ m|^$date_regex|;
  }

  return DateTime->new(
    year => $year , month => $month , day => $day
  );
}

=attr filename_ext

=cut

has filename_ext => (
  is     => 'ro' ,
  isa    => 'HiD_FileExtension' ,
  writer => '_set_filename_ext',
);

=attr filename_title

=cut

has filename_title => (
  is     => 'ro' ,
  isa    => 'Str' ,
  writer => '_set_filename_title' ,
);

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

=attr tags

=cut

### TODO parse tags out of metadata
has tags => (
  is      => 'ro' ,
  isa     => 'ArrayRef',
  default => sub {[]} ,
);

=attr title

=cut

has title => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => '_build_title' ,
);

sub _build_title {
  my $self = shift;

  my $title = $self->get_metadata( 'title' );

  return 'NO TITLE!' unless defined $title;

  return ( ref $title ) ? $$title : $title;
}

no Mouse::Role;
1;
