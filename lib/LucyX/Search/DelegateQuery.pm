package LucyX::Search::DelegateQuery;

use warnings;
use strict;
use Carp;
use Data::Dump qw( dump );
use base qw( Lucy::Search::Query );
use LucyX::Search::DelegateCompiler;

our $VERSION = '0.01';

=head1 NAME

LucyX::Search::DelegateQuery - Apache Lucy query extension for writing your own query class

=head1 SYNOPSIS

Declare your Query class:

 package MyQuery;
 use base qw( LucyX::Search::DelegateQuery );
 
 sub delegate_class { 'Lucy::Search::TermQuery' }
 sub compiler_class { 'MyCompiler' }
 
 1;

Declare your Compiler class:
 
 package MyCompiler;
 use base qw( LucyX::Search::DelegateCompiler );
 
 sub matcher_class  { 'MyMatcher' }
 
 1;

Declare your Matcher class:

 package MyMatcher;
 use base qw( LucyX::Search::DelegateMatcher );
 
 1;

Use them:

 my $query = MyQuery->new( field => 'foo', term => 'bar' );
 my $hits = $searcher->hits( query => $query );


=head1 DESCRIPTION

LucyX::Search::DelegateQuery eases the way to creating custom Lucy
Query classes. You might want to play with alternate scoring mechanisms
or ranking algorithms. DelegateQuery makes that simpler.

DelegateQuery works by letting you extend the native Query classes with a
delegation pattern. For performance reasons it is usually preferable to delegate
most of the heavy lifting to the fast C-based native classes, overriding
only where necessary to customize behaviour. With most Lucy classes
you can simply subclass and override, but the Query architecture can require
a lot more work because of the interrelated nature of the Query/Compiler/Matcher
classes. DelegateQuery helps do that extra work for you.
 
=cut

=head1 METHODS

=head2 delegate_class

Should return the name of the Query class you want to mimic.

=head2 compiler_class

Should return the name of your custom Compiler class.

See also L<LucyX::Search::DelegateCompiler>.

=head2 new( I<args> )

Acts just like new() for the class indicated by delegate_class().

=head2 make_compiler( I<args> )

Returns an instance of compiler_class().

=cut

sub delegate_class { croak "delegate_class not defined in " . shift }
sub compiler_class { croak "compiler_class not defined in " . shift }

my %child_query;

sub new {
    my ( $class, %args ) = @_;
    my $child = $class->delegate_class->new(%args);
    my $self  = $class->SUPER::new();
    $child_query{$$self} = $child;
    return $self;
}

sub make_compiler {
    my ( $self, %args ) = @_;
    my $child_compiler = $child_query{$$self}->make_compiler(%args);
    my $compiler       = $self->compiler_class->new(
        child    => $child_compiler,
        searcher => $args{searcher},
        parent   => $self,
    );
    $compiler->normalize unless $args{subordinate};
    return $compiler;
}

=head2 get_child_query 

Returns the child Query object (instance of delegate_class()).

=cut

sub get_child_query {
    my $self = shift;
    return $child_query{$$self};
}

=head2 set_boost(I<boost>)

Delegates to child Query.

=head2 get_boost

Delegates to child Query.

=cut

sub set_boost { shift->get_child_query->set_boost(@_) }
sub get_boost { shift->get_child_query->get_boost }

sub DESTROY {
    my $self = shift;
    delete $child_query{$$self};
    $self->SUPER::DESTROY;
}

sub AUTOLOAD {
    my $self   = shift;
    my $method = our $AUTOLOAD;
    $method =~ s/.*://;
    my $child = $child_query{$$self};
    if ( $child->can($method) ) {
        return $child->$method(@_);
    }
    croak("no such method $method for $child");
}

1;

__END__

=head1 AUTHOR

Peter Karman, C<< <pkarman at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-lucyx-search-delegatequery at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=LucyX-Search-DelegateQuery>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc LucyX::Search::DelegateQuery


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=LucyX-Search-DelegateQuery>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/LucyX-Search-DelegateQuery>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/LucyX-Search-DelegateQuery>

=item * Search CPAN

L<http://search.cpan.org/dist/LucyX-Search-DelegateQuery/>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2013 Peter Karman.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut
