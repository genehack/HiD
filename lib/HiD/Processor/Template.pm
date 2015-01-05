# ABSTRACT: Use Template Toolkit to publish your HiD files

=head1 SYNOPSIS

    my $processor = HiD::Proccessor::Template->new({ arg => $val });

=head1 DESCRIPTION

Wraps up a L<Template> object and allows it to be used during HiD publication.

=cut

package HiD::Processor::Template;
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

use Template;

has 'tt' => (
  is       => 'ro' ,
  isa      => 'Template' ,
  handles  => [ qw/ process / ],
  required => 1 ,
);

# FIXME this should really probably be a builder on the 'tt' attr
# ...which should be called something more generic
# ...and which should get args via a second attr that's required
sub BUILDARGS {
  my $class = shift;

  my %args = ( ref $_[0] && ref $_[0] eq 'HASH' ) ? %{ $_[0] } : @_;

  # Try to resolve the include path for Template
  my @path = ();

  # It might be set in the configuration file
  if(exists $args{INCLUDE_PATH}) {
      # Try to evaluate as an array
      my $rc = eval { @path = @{ $args{INCLUDE_PATH} }; 1; };
      # If that fails, treat as a string and split ':'
      @path = split /:/, $args{INCLUDE_PATH}
        if !$rc;
  }

  # If we got a default 'path' element, append it to the list.
  if(exists $args{path}) {
      # It should be an array
      my $default_path = delete $args{path};
      my $rc = eval { push @path, @{ $default_path }; 1; };
      # If it's not, split on the ':' in the string
      push @path, split /:/, $default_path
          if !$rc;
  }

  # Finally set the path to the merged path
  $args{INCLUDE_PATH} = \@path;

  return { tt => Template->new( %args ) };
}

=method error

Display the template error message.

=cut

sub error {
    die $Template::ERROR;
}

__PACKAGE__->meta->make_immutable;
1;
