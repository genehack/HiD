# ABSTRACT: The modified form of HiD::Proccessor::Handlebars we use to publish II's blog

=head1 SYNOPSIS

    my $processor = HiD::Proccessor::IIBlog->new({ arg => $val });

=head1 DESCRIPTION

Wraps up a L<Text::Xslate> object and allows it to be used during HiD
publication.

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

use Text::Xslate;

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
        pretty_date => sub { shift->strftime( "%d %b %Y" ) },
      } ,
      path => $path ,
    ),
  };
}

sub process {
  my( $self , $input_ref , $args , $output_ref ) = @_;

  $$output_ref = $self->txs->render_string( $$input_ref , $args );

  return 1;
}

__PACKAGE__->meta->make_immutable;
1;
