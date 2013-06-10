#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'LucyX::Search::DelegateQuery' );
}

diag( "Testing LucyX::Search::DelegateQuery $LucyX::Search::DelegateQuery::VERSION, Perl $], $^X" );
