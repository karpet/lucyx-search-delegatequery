package LucyX::Search::DelegateCompiler;
use strict;
use warnings;
use base qw( Lucy::Search::Compiler );
use Carp;

our $VERSION = '0.01';

=head1 NAME

LucyX::Search::DelegateCompiler - Apache Lucy query extension for writing your own query class

=head1 SYNOPSIS

 package MyCompiler;
 use base qw( LucyX::Search::DelegateCompiler );
 
 sub matcher_class  { 'MyMatcher' }
 
 1;

=head1 DESCRIPTION

See L<LucyX::Search::DelegateQuery>.

=head1 METHODS

This is a subclass of L<Lucy::Search::Compiler>. Only new or overridden methods
are documented here.

=cut

=head2 matcher_class

Should return the name of the LucyX::Search::DelegateMatcher class for
your Query class.

=cut

sub matcher_class { croak "matcher_class not defined for " . shift }

=head2 new( I<args> )

Returns a new instance of the Compiler. Called by make_compiler()
in L<LucyX::Search::DelegateQuery>.

=cut

my %child_compiler;

sub new {
    my ( $class, %args ) = @_;
    my $child = delete $args{child};
    my $self  = $class->SUPER::new(%args);
    $child_compiler{$$self} = $child;
    return $self;
}

=head2 make_matcher( I<args> )

Returns instance of the class indicated by matcher_class().

=cut

sub make_matcher {
    my ( $self, %args ) = @_;
    my $child_matcher = $child_compiler{$$self}->make_matcher(%args);
    return unless $child_matcher;
    my $sort_reader = $args{reader}->obtain("Lucy::Index::SortReader");
    my $sort_cache  = $sort_reader->fetch_sort_cache('option');
    return MyMatcher->new(
        child      => $child_matcher,
        sort_cache => $sort_cache,
    );
}

sub DESTROY {
    my $self = shift;
    delete $child_compiler{$$self};
    $self->SUPER::DESTROY;
}

sub AUTOLOAD {
    my $self   = shift;
    my $method = our $AUTOLOAD;
    $method =~ s/.*://;
    my $child = $child_compiler{$$self};
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
