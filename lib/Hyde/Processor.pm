package Hyde::Processor;
# ABSTRACT: Base class for Hyde Processor objects
use Mouse;

### FIXME figure out whether this makes more sense as a role that would make
###       it easier to see as something implementing a particular interface,
###       for example.


__PACKAGE__->meta->make_immutable;
1;
