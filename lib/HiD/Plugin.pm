# ABSTRACT: Base class for plugins

=head1 SYNOPSIS

    my $plugin = HiD::Plugin->new;
    $plugin->after_publish($hid);

=head1 DESCRIPTION

Base class for plugin object

=cut

package HiD::Plugin;

use Moose;
use namespace::autoclean;

use 5.014;
use utf8;
use autodie;
use warnings   qw/ FATAL utf8 /;
use charnames  qw/ :full           /;
use feature    qw/ unicode_strings /;

sub after_publish { 1 }

1;
