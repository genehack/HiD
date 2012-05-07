package HiD::App::Command::init;
# ABSTRACT: HiD 'init' subcmd - initialize a new site
use Moose;
extends 'HiD::App::Command';

use 5.010;

use autodie;
use YAML::XS qw/ DumpFile /;

has blog => (
  is            => 'ro' ,
  isa           => 'Bool' ,
  traits        => [ 'Getopt' ] ,
  cmd_aliases   => 'b' ,
  documentation => 'include blog-specific features when creating site' ,
);

has github => (
  is            => 'ro' ,
  isa           => 'Bool' ,
  traits        => [ 'Getopt' ] ,
  cmd_aliases   => 'g' ,
  documentation => 'create site ready for publishing on GitHub' ,
);

has title => (
  is            => 'ro' ,
  isa           => 'Str' ,
  traits        => [ 'Getopt' ] ,
  cmd_aliases   => 't' ,
  documentation => 'title for your new site' ,
  default       => 'My Great New Site' ,
);

sub _run {
  my( $self , $opts , $args ) = @_;

  die "TODO: github support" if $self->github;

  mkdir "_$_" for qw/ includes layouts site /;

  open( my $fh , '>' , '_layouts/default.html' );
  print $fh <<EOF;
[% content %]
EOF
  close $fh;

  $self->_init_blog if $self->blog;

  DumpFile( '_config.yml' , {
    title => $self->title ,
  });

  say "Enjoy your new site!";
}

sub _init_blog {
  {
    open( my $fh , '>' , '_layouts/post.html' );
    print $fh <<EOF;
---
layout: default
---
[% page.title %]
[% content %]
EOF
    close( $fh );
  }
  {
    mkdir "_posts";
    open( my $fh , '>' , '_posts/1999-09-09-first-post.markdown' );
    print $fh <<EOF;
---
layout: post
title: My First Post
---
this is the first post in my new blog!
EOF
    close( $fh );
  }
}

__PACKAGE__->meta->make_immutable;
1;
