#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Catalyst::Plugin::EnhancedParams' );
}

diag( "Testing Catalyst::Plugin::EnhancedParams $Catalyst::Plugin::EnhancedParams::VERSION, Perl $], $^X" );
