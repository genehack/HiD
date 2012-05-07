package HiD::Processor;
# ABSTRACT: Base class for HiD Processor objects
use Moose;

### FIXME figure out whether this makes more sense as a role that would make
###       it easier to see as something implementing a particular interface,
###       for example.


__PACKAGE__->meta->make_immutable;
1;
