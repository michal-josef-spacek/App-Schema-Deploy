use strict;
use warnings;

use App::Schema::Deploy;
use English;
use File::Object;
use File::Spec::Functions qw(abs2rel);
use File::Temp qw(tempfile);
use Test::More 'tests' => 9;
use Test::NoWarnings;
use Test::Output;
use Test::Warn;

# Data directory.
my $data = File::Object->new->up->dir('data');

# Test.
unshift @INC, $data->dir('ex1')->s;
require Schema::Foo;
my (undef, $db_file) = tempfile();
@ARGV = (
	'-q',
	'dbi:SQLite:dbname='.$db_file,
	'Schema::Foo',
);
my $ret = App::Schema::Deploy->new->run;
is($ret, 0, 'Deployed SQLite database.');
unlink $db_file;

# Test.
my (undef, $db_file_versioned) = tempfile();
@ARGV = (
	'dbi:SQLite:dbname='.$db_file_versioned,
	'Schema::Foo@0.1.0',
);
my $right_ret = <<'END';
Schema (v0.1.0) from 'Schema::Foo' was deployed to 'dbi:SQLite:dbname=
END
chomp $right_ret;
stdout_like(
	sub {
		$ret = App::Schema::Deploy->new->run;
	},
	qr(^\Q$right_ret\E),
	'Verbose output.',
);
is($ret, 0, 'Deployed SQLite database with inline schema version.');
unlink $db_file_versioned;

# Test.
@ARGV = (
	'-h',
);
$right_ret = help();
stderr_is(
	sub {
		App::Schema::Deploy->new->run;
		return;
	},
	$right_ret,
	'Run help.',
);

# Test.
@ARGV = (
	'dbi:SQLite:dbname=fake.db',
);
$right_ret = help();
stderr_is(
	sub {
		App::Schema::Deploy->new->run;
		return;
	},
	$right_ret,
	'Run without Schema module.',
);

# Test.
@ARGV = (
	'-x',
);
$right_ret = help();
warning_is(
	sub {
		stderr_is(
			sub {
				App::Schema::Deploy->new->run;
				return;
			},
			$right_ret,
			'Run help with bad option.',
		);
	},
	"Unknown option: x\n",
	'Warning about unknown option (x).',
);

# Test.
@ARGV = (
	'dbi:SQLite:dbname=fake.db',
	'bad',
);
eval {
	App::Schema::Deploy->new->run;
};
is($EVAL_ERROR, "Cannot load Schema module.\n", 'Run with bad Schema module.');

sub help {
	my $script = abs2rel(__FILE__);
	if ($OSNAME eq 'MSWin32') {
		$script =~ s/\\/\//msg;
	}
	my $help = <<"END";
Usage: $script [-d] [-h] [-p password] [-q] [-u user] [--version] dsn schema_module[\@schema_version]
	-d				Drop tables.
	-h				Print help.
	-p password			Database password.
	-q				Quiet mode.
	-u user				Database user.
	--version			Print version.
	dsn				Database DSN. e.g. dbi:SQLite:dbname=ex1.db
	schema_module[\@schema_version]	Name of Schema module.
END

	return $help;
}
