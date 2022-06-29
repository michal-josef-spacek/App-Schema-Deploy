use strict;
use warnings;

use App::Schema::Deploy;
use File::Object;
use File::Spec::Functions qw(abs2rel);
use Test::More 'tests' => 2;
use Test::NoWarnings;
use Test::Output;

# Test.
@ARGV = (
	'-h',
);
my $script = abs2rel(File::Object->new->file('04-run.t')->s);
my $right_ret = <<"END";
Usage: $script [-h] [-p password] [-u user] [--version] dsn schema_module
	-h		Print help.
	-p password	Database password.
	-u user		Database user.
	--version	Print version.
	dsn		Database DSN
	schema_module	Name of Schema module.
END
stderr_is(
	sub {
		App::Schema::Deploy->new->run;
		return;
	},
	$right_ret,
	'Run help.',
);
