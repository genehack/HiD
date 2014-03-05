#ABSTRACT: Role for the 'publishes_drafts' attr

package HiD::Role::PublishesDrafts;
use Moose::Role;

requires '_run';

=attr publish_drafts

Flag indicating whether or not to publish draft posts stored in the drafts
directory (which defaults to '_drafts' but can be set with the 'drafts_dir'
config key).

=cut

has publish_drafts=> (
  is          => 'ro' ,
  isa         => 'Bool' ,
  cmd_aliases => 'D' ,
  traits      => [ 'Getopt' ] ,
);

no Moose::Role;
1;
