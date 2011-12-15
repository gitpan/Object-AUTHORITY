package Object::AUTHORITY;

use 5.006;
use strict;

BEGIN {
	$Object::AUTHORITY::AUTHORITY = 'cpan:TOBYINK';
	$Object::AUTHORITY::VERSION   = '0.004';
}

use base qw/Object::Role/;
use Carp qw[croak];
use Scalar::Util qw[blessed];

sub import
{
	my ($class, @args) = @_;
	my ($caller, %args) = $class->parse_arguments(-method => @args);
	$caller = [$caller] unless ref $caller;
	$class->install_method(AUTHORITY => \&AUTHORITY, $_) foreach @$caller;
}

sub AUTHORITY
{
	my ($invocant, $test) = @_;
	$invocant = ref $invocant if blessed($invocant);
	
	my $authority = do {
		no strict 'refs';
		${"$invocant\::AUTHORITY"};
		};
	
	if (scalar @_ > 1 and not reasonably_smart_match($authority, $test))
	{
		defined $authority
			? croak("Invocant ($invocant) has authority '$authority'")
			: croak("Invocant ($invocant) has no authority defined");
	}
	
	return $authority;
}

sub reasonably_smart_match
{
	my ($a, $b) = @_;
	
	if (!defined $b)
	{
		return !defined $a;
	}
	elsif (ref $b eq 'CODE')
	{
		return $b->($a);
	}
	elsif (ref $b eq 'HASH')
	{
		return unless defined $a;
		return exists $b->{$a};
	}
	elsif (ref $b eq 'ARRAY')
	{
		return grep { reasonably_smart_match($a, $_) } @$b;
	}
	elsif (ref $b eq 'Regexp')
	{
		return ($a =~ $b);
	}
	else
	{
		return ($a eq $b);
	}
}

1;

__END__

=head1 NAME

Object::AUTHORITY - adds an AUTHORITY method to your class

=head1 SYNOPSIS

 {
   package MyClass;
   use Object::AUTHORITY;
   BEGIN {
     $MyClass::AUTHORITY = 'cpan:TOBYINK';
     $MyClass::VERSION   = '0.001';
   }
 }
 
 print MyClass->AUTHORITY . "\n";   # prints "cpan:TOBYINK\n";
 MyClass->AUTHORITY('cpan:FOO');    # assertion fails, croaks.

=head1 DESCRIPTION

This module adds an C<AUTHORITY> function to your package, which works along
the same lines as the C<VERSION> function.

The authority of a package can be defined like this:

 package MyApp;
 BEGIN { $MyApp::AUTHORITY = 'cpan:JOEBLOGGS'; }

The authority should be a URI identifying the person, team, organisation
or trained chimp responsible for the release of the package. The
pseudo-URI scheme C<< cpan: >> is the most commonly used identifier.

=head2 C<< AUTHORITY >>

Called with no parameters returns the authority of the module.

=head2 C<< AUTHORITY($test) >>

If passed a test, will croak if the test fails. The authority is tested
against the test using something approximating Perl 5.10's smart match
operator. (Briefly, you can pass a string for C<eq> comparison, a regular
expression, a code reference to use as a callback, or an array reference
that will be grepped.)

=head2 Utility Function

=over

=item C<< Object::AUTHORITY::reasonably_smart_match($a, $b) >>

Object::AUTHORITY exposes its smart match implementation in case
classes wish to reuse it for their own custom C<AUTHORITY> methods. (There
are various interesting use cases for custom C<AUTHORITY> methods, just as
there are for custom C<can> and C<isa> methods.)

The C<< $a >> parameter is always assumed to be a simple scalar.

=back

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=Object-AUTHORITY>.

=head1 SEE ALSO

=over

=item * I<Object::AUTHORITY> (this module) - an AUTHORITY method for your class

=item * L<authority::shared> - a more sophisticated AUTHORITY method for your class

=item * L<UNIVERSAL::AUTHORITY> - an AUTHORITY method for every class (deprecated)

=item * L<UNIVERSAL::AUTHORITY::Lexical> - an AUTHORITY method for every class, within a lexical scope

=item * L<authority> - load modules only if they have a particular authority

=back

Background reading: L<http://feather.perl6.nl/syn/S11.html>,
L<http://www.perlmonks.org/?node_id=694377>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2011 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

