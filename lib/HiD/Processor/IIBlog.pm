# ABSTRACT: The modified form of HiD::Proccessor::Handlebars we use to publish II's blog

=head1 SYNOPSIS

    my $processor = HiD::Proccessor::IIBlog->new({ arg => $val });

=head1 DESCRIPTION

Wraps up a L<Text::Xslate> object and allows it to be used during HiD
publication.

=head2 Custom Xslate functions

The L<Text::Xslate> object created by this processor provides a 
few custom utility functions.

=over

=item commafy( \@list )

Joins the items of the list with commas. Oxford comma not included.

=item lc( $string )

Lowercases the string.

=item lightbox( img => $img, alt => $alt, width => $width )

Creates a ligthbox. Both C<img> and C<alt> are mandatory. C<width>,
if not provided, defaults to C<300>.

=item pretty_date( $datetime )

Takes in a L<DateTime> object and returns a string of the format
C<17 Aug 2017>.


=back

=cut

package HiD::Processor::IIBlog;

use Moose;
extends 'HiD::Processor';
use namespace::autoclean;

use 5.014; # strict, unicode_strings
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;

use Text::Xslate qw/ mark_raw /;

has 'txs' => (
  is       => 'ro' ,
  isa      => 'Text::Xslate' ,
  required => 1 ,
);

# FIXME this should really probably be a builder on the 'tt' attr
# ...which should be called something more generic
# ...and which should get args via a second attr that's required
sub BUILDARGS {
  my $class = shift;

  my %args = ( ref $_[0] && ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  my $path = [ '.' , './_layouts' ];
  push @$path , './_includes' if -e -d './_includes';

  return {
    txs => Text::Xslate->new(
      function => {
        commafy     => sub { my $a = shift; join ',' , @$a },
        lc          => sub { lc( shift ) } ,
        lightbox    => \&lightbox,
        pretty_date => sub { shift->strftime( "%d %b %Y" ) },
      } ,
      path => $path,
      warn_handler => sub {
        my $self = shift;
        say($self);
        die;
      }
    ),
  };
}

sub process {
  my( $self , $input_ref , $args , $output_ref ) = @_;

  $$output_ref = $self->txs->render_string( $$input_ref , $args );

  return 1;
}

sub _lightbox {
  my %args = @_;

  my $img   = $args{img}   // die "lightbox needs img arg";
  my $width = $args{width} //= 300;
  my $alt   = $args{alt}   // die "lightbox needs alt arg";

  return mark_raw(<<EOHTML);
<a href="$img" class="lightbox">
  <img src="$img" width="$width" alt="$alt" />
</a>
EOHTML
}

__PACKAGE__->meta->make_immutable;
1;
