package HiD::Command::init;
# ABSTRACT: initialize a new site
use 5.010;
use Mouse;
extends 'HiD::Command';

use YAML::XS qw/ DumpFile /;

sub execute {
  my( $self , $opts , $args ) = @_;

  ### FIXME all sorts of argument processing stuff here
  # --title
  # --github
  # --blog
  #  ... etc.

  for my $dir ( qw/ includes layouts posts site / ) {
    mkdir "_$dir";
  }

  DumpFile( '_config.yml' , {
    title => 'My Great New Site' ,
  });

  say "Enjoy your new site!";
}

__PACKAGE__->meta->make_immutable;
1;
