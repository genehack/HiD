use 5.010;
package HiD::Page;
# ABSTRACT: Pages that are converted during the output process
use Moose;
with 'HiD::Role::IsConverted';
with 'HiD::Role::IsPublished';

use File::Basename  qw/ fileparse /;
use File::Path      qw/ make_path /;
use Path::Class     qw/ file / ;

=head1 NOTE

Also consumes L<HiD::Role::IsConverted> and L<HiD::Role::IsPublished>; see
documentation for that role as well if you're trying to figure out how an
object from this class works.

=method get_default_layout

=cut

sub get_default_layout { 'default' }

=method publish

=cut

sub publish {
  my $self = shift;

  my( undef , $dir ) = fileparse( $self->output_filename );

  make_path $dir unless -d $dir;

  open( my $out , '>' , $self->output_filename ) or die $!;
  print $out $self->rendered_content;
  close( $out );
}

# used to populate the 'url' attr in Role::IsPublished
sub _build_url {
  my $self = shift;

  my $format = $self->get_metadata( 'permalink' ) // 'none';

  my $source = $self->source;
  my $path_frag = $self->input_path;
  $path_frag =~ s/^$source//;

  my $naive = join '/' , $path_frag , $self->basename;

  my $url;
  given( $format ) {
    when( 'none'   ) { $url = $naive . '.html' }
    when( 'pretty' ) { $url = $naive . '/'     }
    default          { $url = "/$format"       }
  }

  $url =~ s|//+|/|g;

  return $url;
}

__PACKAGE__->meta->make_immutable;
1;
