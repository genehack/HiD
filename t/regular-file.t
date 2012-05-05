use Test::Routine::Util;
use Test::More;

use lib 't/lib';

run_tests( "regular file" => 'Test::HiD::RegularFile' );

done_testing;
