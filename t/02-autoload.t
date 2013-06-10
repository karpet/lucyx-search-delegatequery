#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;

use Lucy;

{

    package MyQuery;
    use base qw( LucyX::Search::DelegateQuery );

    sub delegate_class {'Lucy::Search::TermQuery'}
    sub compiler_class {'MyCompiler'}

}
{

    package MyCompiler;
    use base qw( LucyX::Search::DelegateCompiler );

    sub matcher_class {'MyMatcher'}

}
{

    package MyMatcher;
    use base qw( LucyX::Search::DelegateMatcher );

}

ok( my $query = MyQuery->new( field => 'foo', term => 'bar' ),
    "new MyQuery" );

is( $query->get_field, 'foo', 'get_field' );
is( $query->get_term,  'bar', 'get_term' );
