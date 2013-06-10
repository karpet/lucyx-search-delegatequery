package LucyX::Search::DelegateMatcher;
use strict;
use warnings;
use base qw( Lucy::Search::Matcher );
use Carp;

our $VERSION = '0.01';

=head1 NAME

LucyX::Search::DelegateMatcher - Apache Lucy query extension for writing your own query class

=head1 SYNOPSIS

 package MyMatcher;
 use base qw( LucyX::Search::DelegateMatcher );
 
 1;

=head1 DESCRIPTION

See L<LucyX::Search::DelegateQuery>.

=head1 METHODS

This is a subclass of L<Lucy::Search::Matcher>. Only new or overridden methods
are documented here.

=cut

=head2 new( I<args> )

Returns a new instance of DelegateMatcher.

=cut

my %child_matcher;

sub new {
    my $class = shift;
    my %args  = @_;
    my $child = delete $args{child};
    my $self  = $class->SUPER::new(%args);
    $child_matcher{$$self} = $child;
    return $self;
}

sub DESTROY {
    my $self = shift;
    delete $child_matcher{$$self};
    $self->SUPER::DESTROY;
}

=head2 get_child_matcher 

Returns child Matcher object.

=cut

sub get_child_matcher { $child_matcher{ ${ +shift } } }

=head2 next

Delegates to the child Matcher's method.

=head2 get_doc_id 

Delegates to the child Matcher's method.

=cut

# Delegate next() and get_doc_id() to the child Matcher explicitly,
# rather than relying on AUTOLOAD,
# since they are required abstract methods
sub next       { shift->get_child_matcher->next }
sub get_doc_id { shift->get_child_matcher->get_doc_id }

sub AUTOLOAD {
    my $self   = shift;
    my $method = our $AUTOLOAD;
    $method =~ s/.*://;
    my $child = $child_matcher{$$self};
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
