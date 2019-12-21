use v5.12;
use strict;
use warnings;

package Data::Validate::CSV::Types;

our $AUTHORITY = 'cpan:TOBYINK';
our $VERSION   = '0.003';

use Type::Library -base, -declare => qw(
	Table
	Row
	Cell
	Column
	Schema
	Note
	SingleValueCell
	MultiValueCell
	ValidJson
	ValidJsonObject
	ValidJsonArray
	WellFormedXml
);

BEGIN {
	require Type::Utils;
	Type::Utils::extends(qw( Types::Standard ));
};

use Types::Path::Tiny qw( Path );
use Type::Tiny::Class ();
use Type::Tiny::Role ();

__PACKAGE__->add_type(Type::Tiny::Class->new(
	name     => Table,
	class    => 'Data::Validate::CSV::Table',
));

__PACKAGE__->add_type(Type::Tiny::Class->new(
	name     => Note,
	class    => 'Data::Validate::CSV::Note',
	coercion => [
		HashRef,        q{ 'Data::Validate::CSV::Note'->new($_) },
	],
));

__PACKAGE__->add_type(Type::Tiny::Class->new(
	name     => Schema,
	class    => 'Data::Validate::CSV::Schema',
	coercion => [
		HashRef,        q{ 'Data::Validate::CSV::Schema'->new_from_hashref($_) },
		Str|ScalarRef,  q{ 'Data::Validate::CSV::Schema'->new_from_json($_) },
		Path,           q{ 'Data::Validate::CSV::Schema'->new_from_file($_) },
	],
));

__PACKAGE__->add_type(Type::Tiny::Class->new(
	name     => Column,
	class    => 'Data::Validate::CSV::Column',
	coercion => [
		HashRef,        q{ 'Data::Validate::CSV::Column'->new($_) },
	],
));

__PACKAGE__->add_type(Type::Tiny::Class->new(
	name     => Row,
	class    => 'Data::Validate::CSV::Row',
));

__PACKAGE__->add_type(Type::Tiny::Role->new(
	name     => Cell,
	role     => 'Data::Validate::CSV::Cell',
));

__PACKAGE__->add_type(Type::Tiny::Class->new(
	name     => SingleValueCell,
	class    => 'Data::Validate::CSV::SingleValueCell',
));

__PACKAGE__->add_type(Type::Tiny::Class->new(
	name     => MultiValueCell,
	class    => 'Data::Validate::CSV::MultiValueCell',
));

require JSON::PP;

__PACKAGE__->add_type(
	name       => ValidJson,
	parent     => Str,
	constraint => 'eval { JSON::PP::decode_json($_); 1 }',
);

__PACKAGE__->add_type(
	name       => ValidJsonObject,
	parent     => ValidJson,
	constraint => q{/\A\s*\{/s},
	inlined    => sub {
		my $var = pop;
		return (
			Str->inline_check($var),
			sprintf('%s =~ /\A\s*\{/s', $var),
			sprintf('eval { JSON::PP::decode_json(%s); 1 }', $var),
		);
	},
);

__PACKAGE__->add_type(
	name       => ValidJsonArray,
	parent     => ValidJson,
	constraint => q{/\A\s*\[/s},
	inlined    => sub {
		my $var = pop;
		return (
			Str->inline_check($var),
			sprintf('%s =~ /\A\s*\[/s', $var),
			sprintf('eval { JSON::PP::decode_json(%s); 1 }', $var),
		);
	},
);

require XML::LibXML;

__PACKAGE__->add_type(
	name       => WellFormedXml,
	parent     => Str,
	constraint => 'eval { !! "XML::LibXML"->load_xml(string => $_) }',
);

__PACKAGE__->make_immutable;

1;
