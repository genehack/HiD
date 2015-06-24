#! perl

use strict;
use warnings;

use lib 't/lib';

use Test::More;

use HiD::Post;
use HiD;

my %tests = (
    'no twitter handles' => undef,
    'scalar (one) twitter handles' => 'genehack',
    'array twitter handles' => [ 'genehack', 'yenzie' ],
);

plan tests => scalar keys %tests;

while ( my( $label, $data ) = each %tests ) {
    subtest $label => sub { test_me($data) };
}

sub test_me {
    my $handles = shift;

    my $metadata = {};
    if ( $handles ) {
        $metadata->{twitter} = $handles;
    }

    my $post = HiD::Post->new(
        metadata       => $metadata,
        content        => 'dummy',
        dest_dir       => '.',
        hid            => HiD->new,
        input_filename => __FILE__,
        layouts        => {},
    );

    my @handles = ref $handles ? @$handles : $handles ? ( $handles ) : ();

    is $post->twitter => $handles[0], 'twitter';

    is !!$post->has_twitter_handles => !!@handles, 'has_twitter_handles';


    is_deeply $post->twitter_handles => [ @handles ], 'twitter_handles';
    is_deeply [ $post->all_twitter_handles ] => [ @handles ], 'all_twitter_handles';
};


