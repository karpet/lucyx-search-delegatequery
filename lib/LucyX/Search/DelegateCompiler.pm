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

Should return the name of the LucyX::Search::DelegateMatcher subclass for
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

=head2 get_child_compiler

Returns the internal Compiler object.

=cut

sub get_child_compiler {
    return $child_compiler{ ${ +shift } };
}

=head2 get_weight

Delegates to child.

=cut

sub get_weight {
    my $self = shift;
    if ( !exists $child_compiler{$$self} ) {
        return $self->SUPER::get_weight(@_);
    }
    return $child_compiler{$$self}->get_weight(@_);
}

=head2 get_similarity

Delegates to child.

=cut

sub get_similarity {
    my $self = shift;
    if ( !exists $child_compiler{$$self} ) {
        return $self->SUPER::get_similarity(@_);
    }
    return $child_compiler{$$self}->get_similarity(@_);
}

=head2 normalize

Delegates to child.

=cut

sub normalize {
    my $self = shift;
    if ( !exists $child_compiler{$$self} ) {
        return $self->SUPER::normalize(@_);
    }
    return $child_compiler{$$self}->normalize(@_);
}

=head2 sum_of_squared_weights

Delegates to child.

=cut

sub sum_of_squared_weights {
    my $self = shift;
    if ( !exists $child_compiler{$$self} ) {
        return $self->SUPER::sum_of_squared_weights(@_);
    }
    return $child_compiler{$$self}->sum_of_squared_weights();
}

=head2 highlight_spans

Delegates to child.

=cut

sub highlight_spans {
    my $self = shift;
    if ( !exists $child_compiler{$$self} ) {
        return $self->SUPER::highlight_spans(@_);
    }
    return $child_compiler{$$self}->highlight_spans(@_);
}

=head2 make_matcher( I<args> )

Returns instance of the class indicated by matcher_class().

=cut

sub make_matcher {
    my ( $self, %args ) = @_;
    my $child_matcher = $child_compiler{$$self}->make_matcher(%args);
    return unless $child_matcher;
    return $self->matcher_class->new( child => $child_matcher, );
}

sub DESTROY {
    my $self = shift;
    delete $child_compiler{$$self};
    $self->SUPER::DESTROY;
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
