package HiD::Role::IsPost;
use Mouse::Role;
with 'HiD::Role::IsProcessed';

use DateTime;
use HiD::Types;
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
);

sub _build_date {
  my $self = shift;

  my $date_source = $self->get_metadata( 'date' ) // $self->filename;

  my( $year , $month , $day ) = $date_source
    =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})/;

  return DateTime->new(
    year => $year , month => $month , day => $day
  );
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
