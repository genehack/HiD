# ABSTRACT: Use Text::Handlebars to publish your HiD files

=head1 SYNOPSIS

    my $processor = HiD::Proccessor::Handlebars->new({ arg => $val });

=head1 DESCRIPTION

Wraps up a L<Text::Handlebars> object and allows it to be used during HiD publication.

=cut

package HiD::Processor::Handlebars;

use Moose;
extends 'HiD::Processor';
use namespace::autoclean;

use 5.014;  # strict, unicode_strings
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;

use Text::Handlebars;

has 'hb' => (
  is       => 'ro' ,
  isa      => 'Text::Handlebars' ,
  required => 1 ,
);

# FIXME this should really probably be a builder on the 'tt' attr
# ...which should be called something more generic
# ...and which should get args via a second attr that's required
sub BUILDARGS {
  my $class = shift;

  my %args = ( ref $_[0] && ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  return { hb => Text::Handlebars->new( %args ) };
}

sub process {
  my( $self , $input_ref , $args , $output_ref ) = @_;

  $$output_ref = $self->hb->render_string( $$input_ref , $args );

  return 1;
}

__PACKAGE__->meta->make_immutable;
1;
