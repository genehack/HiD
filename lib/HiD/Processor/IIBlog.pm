# ABSTRACT: The modified form of HiD::Proccessor::Handlebars we use to publish II's blog

=head1 SYNOPSIS

    my $processor = HiD::Proccessor::IIBlog->new({ arg => $val });

=head1 DESCRIPTION

Wraps up a L<Text::Handlebars> object and allows it to be used during HiD
publication.

This subclasses HiD::Proccessor::Handlebars and adds a bunch of helper
functions to make it possible for us to publish our blog despite some of the
limitations of the Handlebars templating language.

=cut

package HiD::Processor::IIBlog;
use Moose;
extends 'HiD::Processor';
use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;
use feature     qw/ unicode_strings /;

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

  return {
    hb => Text::Handlebars->new(
      helpers => {
        indexedeach => sub {
          my( $context , $items , $options ) = @_;

          die "must provide limit for indexed_each"
            unless defined $options->{hash}{limit};

          my $limit = $options->{hash}{limit} - 1;

          die "limit must not be negative" if $limit < 0;

          my $ret='';

          foreach( 0 .. $limit ) {
            $ret .= $options->{fn}->($items->[$_]);
          }
          return $ret;
        },
        commafy => sub {
          my( $context , $list ) = @_;
          return join ',' , @$list;
        },
        pretty_date => sub {
          my( $context, $dt ) = @_;
          return $dt->strftime( "%d %b %Y" );
        }
      },
    ),
  };
}

sub process {
  my( $self , $input_ref , $args , $output_ref ) = @_;

  $$output_ref = $self->hb->render_string( $$input_ref , $args );

  return 1;
}

__PACKAGE__->meta->make_immutable;
1;
