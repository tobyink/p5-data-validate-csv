{
	sub parse_args {
		require ExtUtils::MakeMaker;
		require Text::ParseWords;
		ExtUtils::MakeMaker::parse_args(
			my $tmp = {},
			Text::ParseWords::shellwords($ENV{PERL_MM_OPT} || ''),
			@ARGV,
		);
		return $tmp->{ARGS} || {};
	}
	use ExtUtils::HasCompiler 0.014 'can_compile_loadable_object';
	my $can_xs;
	sub can_xs {
		return $can_xs if defined $can_xs;
		$can_xs = can_compile_loadable_object(quiet => 1) ? 1 : 0;
	}
	my $want_pp;
	sub want_pp {
		return $want_pp if defined $want_pp;
		$want_pp = parse_args()->{PUREPERL_ONLY} ? 1 : 0
	}
}

if (want_pp) {
	$meta->{prereqs}{test}{requires}{'Text::CSV'} = '0';
}
elsif (eval { require Text::CSV_XS; 1 }) {
	$meta->{prereqs}{test}{requires}{'Text::CSV_XS'} = '0';
}
elsif (eval { require Text::CSV; 1 }) {
	$meta->{prereqs}{test}{requires}{'Text::CSV'} = '0';
}
elsif (can_xs) {
	$meta->{prereqs}{test}{requires}{'Text::CSV_XS'} = '0';
}
else {
	$meta->{prereqs}{test}{requires}{'Text::CSV'} = '0';
}