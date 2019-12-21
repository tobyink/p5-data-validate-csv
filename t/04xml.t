=pod

=encoding utf-8

=head1 PURPOSE

Test the C<xml> datatype.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2019 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=cut

use strict;
use warnings;
use Test::More;

use Data::Validate::CSV;
use Data::Validate::CSV::Types qw( Table );

my $table = Table->new(
	input      => \*DATA,
	has_header => !!1,
	schema     => {
		tableSchema => {
			columns => [
				{ name => 'id',   datatype => 'string' },
				{ name => 'data', datatype => { base => 'xml' } },
			],
		}
	},
);

my @rows = $table->all_rows;

is(scalar(@rows), 3, 'read 3 rows of data');

isa_ok(
	$rows[0]->cells->[1]->inflated_value,
	'XML::LibXML::Document',
);

isa_ok(
	$rows[1]->cells->[1]->inflated_value,
	'XML::LibXML::Document',
);

is(
	$rows[1]->cells->[1]->inflated_value->documentElement->tagName,
	'foo',
);

is(
	$rows[1]->cells->[1]->inflated_value->documentElement->{bar},
	'42',
);

is_deeply(
	$rows[2]->cells->[1]->inflated_value,
	"<foo></baz>",
);

done_testing;

__DATA__
id,data
simple,"<foo/>"
harder,"<foo bar='42'><baz /></foo>"
invalid,"<foo></baz>"