package Catalyst::Plugin::EnhancedParams;

use warnings;
use strict;

=head1 NAME

Catalyst::Plugin::EnhancedParams - Enhances Catalyst parameter processing behaviour

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

This module enhances Catalyst parameter processing support by adding hash (could
also be viewed as object) parameters. It integrates well with Catalyst providing
these hash parameters through the already used C<param()> method of the request 
object but doesn't destroy the original parameter data so it's still somewhat 
L<< CGI >>-compatible.

It further provides helper methods C<param()>, C<parameters()> and its alias 
C<params()> on the Catalyst context namespace so that you can be even lazier 
and just use C<$c->param('field_name')> instead of C<$c->req->param('field_name')>.

In MyApp.pm:

    use Catalyst qw/
        ....
        EnhancedParams
    /;
    
In your template file (or whatever you use as your view):

    <form>
      <input type="text" name="person[name]" />
      <input type="text" name="person[age]" />
    </form>
    
Inside the corresponding controller action:

    # using the alias at the context object
    my $person = $c->param('person');
    
    $c->log->debug("Person name: $person->{name}");
    $c->log->debug("Person age: $person->{age}");

    # assuming these are the only required fields
    my $obj = $c->model('Person')->create($person);

=head1 METHODS

=cut

=head2 $c->param(...)

Alias to C<$c->request->param(...)>.

=cut
sub param { shift->request->param(@_) }

=head2 $c->params

=head2 $c->parameters

Alias to C<$c->request->parameters>.

=cut
sub parameters { shift->request->parameters(@_) }
*params = \&parameters;

=head2 prepare_body

Catalyst pluggable action. Described below.

=cut

=head1 INTERACTION WITH CATALYST

C<Catalyst::Plugin::EnhancedParams> plugs into this handler and post-processes
its output, translating parameters which would be accessed as C<param('param_name[key]')> 
to C<param('param_name')->{key}>.

Having the parameters in this form is really useful if you want to do stuff 
such as directly passing them to the model (e.g. the C<create()> method of L<DBIx::Class>).

The original C<param('name[key]')> still works. 

B<IMPORTANT NOTE:> If there was already a parameter named "param_name" in the 
above example it would be overriden.

=cut
sub prepare_body {
	my $c = shift;

	# Avoid infinite recursion
    return if defined $c->request->{_body};
	
	$c->NEXT::prepare_body(@_);

	while ( my ($name, $value) = each %{$c->params} ) {
		
		# tries to match strings like this: hash[key]
		if (my ($param, $key) = ($name =~ /^([^\[]+)\[([^\]]+)\]$/)) {
			$c->params->{$param}->{$key} = $value;
		}

	}
}

=head1 LIMITATIONS

Currently, only one "hash level" is supported, i.e., you can't use 
C<field_name[key1][key2]> and expect it to work. It won't do anything.
This feature may be added in future versions.

=head1 AUTHOR

Nilson Santos Figueiredo Júnior, C<< <nilsonsfj at cpan.org> >>

=head1 BUGS

Please report any bugs and feature requests directly to the author.
If you ask nicely it will probably be implemented.

=head1 SEE ALSO

L<Catalyst>, L<Catalyst::Request>

=head1 COPYRIGHT & LICENSE

Copyright 2006 Nilson Santos Figueiredo Júnior, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Catalyst::Plugin::EnhancedParams
