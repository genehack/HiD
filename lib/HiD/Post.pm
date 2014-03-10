# ABSTRACT: Blog posts

=head1 SYNOPSIS

    my $post = HiD::Post->new({
      dest_dir       => 'path/to/output/dir' ,
      hid            => $master_hid_object ,
      input_filename => 'path/to/file/for/this/post' ,
      layouts        => $hashref_of_hid_layout_objects,
    });

=head1 DESCRIPTION

Class representing a "blog post" object.

=cut

package HiD::Post;

use Moose;
with
  'HiD::Role::IsConverted',
  'HiD::Role::IsPost',
  'HiD::Role::IsPublished';
with 'HiD::Role::DoesLogging'; # this one last b/c it needs method delegated
                               # by initial roles

use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

use File::Basename  qw/ fileparse /;
use File::Path      qw/ make_path /;
use String::Errf    qw/ errf /;

=for Pod::Coverage BUILD

=cut

sub BUILD {
  my $self = shift;

  if ( defined $self->get_metadata('published')
         and not $self->get_metadata('published')) {
    $self->LOGWARN(
      sprintf "Skipping %s because 'published' flag is false" , $self->input_filename
    );
    die;
  }
}

=method get_default_layout

The default layout used when publishing a L<HiD::Post> object. (Defaults to 'post'.)

=cut

sub get_default_layout { 'post' }

=method publish

Publish -- convert, render through any associated layouts, and write out to
disk -- this data from this object.

=cut

sub publish {
  my $self = shift;

  my( undef , $dir ) = fileparse( $self->output_filename );

  make_path $dir unless -d $dir;

  open( my $out , '>:utf8' , $self->output_filename ) or die $!;
  print $out $self->rendered_content;
  close( $out );
}

# override
my $date_regex = qr|([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})|;

sub _build_basename {
  my $self = shift;
  my $ext = '.' . $self->ext;
  my $basename = fileparse( $self->input_filename , $ext );

  if( $self->get_config( 'publish_drafts' )) {
    if ( $self->is_draft ) {
      # not fatal to lack a date if you're a draft, but okay to have one
      $basename =~ s/^.*?$date_regex-//;
      return $basename;
    }
  }

  $basename =~ s/^.*?$date_regex-// or die "no date in filename";
  return $basename;
}

sub _build_url {
  my $self = shift;

  my %formats = (
    simple => '/posts/%{year}/%{month}/%{title}.html',
    date   => '/%{categories}s/%{year}s/%{month}s/%{day}s/%{title}s.html' ,
    ii     => '%{year}s/%{month}s/%{day}s/%{title}s.html' ,
    pretty => '/%{categories}s/%{year}s/%{month}s/%{day}s/%{title}s/' ,
    none   => '/%{categories}s/%{title}s.html' ,
  );

  my $permalink_format = $self->get_metadata( 'permalink' ) //
   $self->get_config('permalink') // 'date';

  $permalink_format = $formats{$permalink_format}
    if exists $formats{$permalink_format};

  my $categories = ( join '/' , @{ $self->categories } ) || '';
  my $day        = $self->strftime( '%d' , $self->day   );
  my $month      = $self->strftime( '%m' , $self->month );

  my $permalink = errf $permalink_format , {
    categories => $categories ,
    day        => $day ,
    i_day      => $self->day,
    i_month    => $self->month,
    month      => $month ,
    title      => $self->basename ,
    year       => $self->year ,
  };

  $permalink =~ s|//+|/|g;

  return $permalink;
}

__PACKAGE__->meta->make_immutable;
1;
