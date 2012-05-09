package HiD::Role::IsPost;
use Moose::Role;

use DateTime;
use File::Basename qw/ fileparse /;
use HiD::Types;
use YAML::XS;

my $date_regex = qr|([0-9]{4})-([0-9]{2})-([0-9]{2})|;

# override
sub _build_basename {
  my $self = shift;
  my $ext = '.' . $self->ext;
  my $basename = fileparse( $self->input_filename , $ext );
  $basename =~ s/^$date_regex-//;
  return $basename;
}

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
  handles => {
    day      => 'day' ,
    month    => 'month' ,
    strftime => 'strftime' ,
    year     => 'year' ,
  },
  default => sub {
    my $self = shift;

    ### FIXME configurable?
    my $date_regex = qr|([0-9]{4})-([0-9]{2})-([0-9]{2})|;

    my( $year , $month , $day );
    if ( my $date = $self->get_metadata( 'date' )) {
      ( $year , $month , $day ) = $date
        =~ m|^$date_regex|;
    }
    else {
      ( $year , $month , $day ) = $self->input_filename
        =~ m|^_posts/$date_regex-|;
    }

    return DateTime->new(
      year  => $year ,
      month => $month ,
      day   => $day
    );
  },
);

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

no Moose::Role;
1;
