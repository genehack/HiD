use Test::Routine::Util;
use Test::More;

use lib 't/lib';

run_tests( "page" => 'Test::HiD::Page' );

#run_tests( "" => 'Test::HiD::Page' => { page => HiD::Page->new({
#
#}) } );


done_testing;
