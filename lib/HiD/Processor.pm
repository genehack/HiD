# ABSTRACT: Base class for HiD Processor objects

=head1 SYNOPSIS

    my $processor = HiD::Processor->new({ %args });

=head1 DESCRIPTION

Base class for HiD Processor objects.

To create a new HiD Processor type, extend this class with something that
implements a 'process' method.

=cut

package HiD::Processor;

use Moose;
use namespace::autoclean;

use 5.014; # strict, unicode_strings
use utf8;
use autodie;
use warnings    qw/ FATAL  utf8     /;
use open        qw/ :std  :utf8     /;
use charnames   qw/ :full           /;

### FIXME figure out whether this makes more sense as a role that would make
###       it easier to see as something implementing a particular interface,
###       for example.

=method process

=cut

sub process { die "override this" }


__PACKAGE__->meta->make_immutable;
1;
