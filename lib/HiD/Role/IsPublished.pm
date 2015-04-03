# ABSTRACT: Role to be consumed by classes that are published during processing

=head1 SYNOPSIS

    package MyThingThatIsPublished;
    use Moose;
    with 'HiD::Role::IsPublished';

    ...

    1;

=head1 DESCRIPTION

This role is for all objects that go through the HiD publishing process. It
provides attributes and methods that are needed during that process.

=cut

package HiD::Role::IsPublished;

use Moose::Role;
use namespace::autoclean;

use 5.014; # strict, unicode_strings
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;

use Path::Tiny;

use HiD::Types;

requires 'publish';

=attr basename ( ro / isa = Str / lazily built from input_filename )

Basename of the file for this object (that is, without any leading directory
path and without any file extension).

=cut

has basename => (
  is      => 'ro',
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => '_build_basename',
);

sub _build_basename {
  my $self = shift;
  my $ext = '.' . $self->ext;
  return path( $self->input_filename )->basename( $ext );
}

=attr baseurl

Base URL for use in Templates

=cut

has baseurl => (
  is      => 'ro',
  isa     => 'Str',
  lazy    => 1,
  builder => '_build_baseurl',
);

sub _build_baseurl {
  my $self = shift;

  my $base_url = $self->config->{baseurl};
  if( defined $base_url ) {
    return $base_url;
  }
  return '/';
}

=attr dest_dir ( ro / isa = HiD_DirPath / required )

The path to the directory where the output_filename will be written.

=cut

has dest_dir => (
  is       => 'ro' ,
  isa      => 'HiD_DirPath' ,
  required => 1 ,
);

=attr ext ( ro / isa = HiD_FileExtension / lazily built from filename )

The extension on the input filename of the consuming object.

=cut

has ext => (
  is      => 'ro' ,
  isa     => 'HiD_FileExtension' ,
  lazy    => 1 ,
  default => sub {
    my $self = shift;
    my( $extension ) = $self->input_filename =~ m|\.([^.]+)$|;
    return $extension;
  },
);

=attr input_filename ( ro / isa = HiD_FilePath / required )

The path of the consuming object's file. Required for instantiation.

=cut

has input_filename => (
  is       => 'ro' ,
  isa      => 'HiD_FilePath' ,
  required => 1 ,
);

=attr input_path ( ro / isa = HiD_DirPath / lazily built from input_filename )

The path component of the input filename.

=cut

has input_path => (
  is      => 'ro' ,
  isa     => 'HiD_DirPath' ,
  lazy    => 1 ,
  default => sub { path( shift->input_filename )->parent->stringify() },
);

=attr output_filename

Path to the file that will be created when the C<write> method is called.

=cut

has output_filename => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  default => sub {
    my $self = shift;

    my $url = $self->url;
    $url .= 'index.html' if $url =~ m|/$|;

    return path( $self->dest_dir , $url )->stringify;
  },
);

=attr source ( ro / isa = Str )

Same as 'source' in HiD.pm. Normally shouldn't need to be provided.

=cut

has source => (
  is      => 'ro' ,
  isa     => 'Str' ,
  default => '' ,
);

=attr url ( ro / isa = Str / lazily built from output_filename and dest_dir )

The URL to the output path for the written file.

=cut

has url => (
  is      => 'ro' ,
  isa     => 'Str' ,
  lazy    => 1 ,
  builder => '_build_url' ,
);

no Moose::Role;
1;
