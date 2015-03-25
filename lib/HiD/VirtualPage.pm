# ABSTRACT: Pages injected during the build process that don't have corresponding files

=head1 SYNOPSIS

    my $page = HiD::VirtualPage->new({
      output_filename => 'path/to/output/file' ,
      content         => 'content to go into file',
    });

=head1 DESCRIPTION

Class representing a virtual "page" object -- that is, a page that will be
generated during the publishing process, but that doesn't have a direct
on-disk component or input prior to that. VirtualPages need to have their
content completely built and provided at the time they are
instantiated. Examples would be Atom and RSS feeds.

=cut

package HiD::VirtualPage;

use Moose;
use namespace::autoclean;

use 5.014; # strict, unicode_strings
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;

use Path::Tiny;

=attr output_filename

=cut

has output_filename => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

has content => (
  is       => 'ro' ,
  isa      => 'Str' ,
  required => 1 ,
);

=method publish

Publish -- write out to disk -- this data from this object.

=cut

sub publish {
  my $self = shift;

  my $out = path( $self->output_filename );
  my $dir = $out->parent;

  $dir->mkpath() unless $dir->is_dir;

  $out->spew_utf8( $self->content );
}

__PACKAGE__->meta->make_immutable;
1;
