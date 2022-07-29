package App::Schema::Deploy;

use strict;
use warnings;

use English;
use Error::Pure qw(err);
use Getopt::Std;

our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Object.
	return $self;
}

# Run.
sub run {
	my $self = shift;

	# Process arguments.
	$self->{'_opts'} = {
		'h' => 0,
		'p' => '',
		'u' => '',
	};
	if (! getopts('hp:u:', $self->{'_opts'}) || @ARGV < 1
		|| $self->{'_opts'}->{'h'}) {

		print STDERR "Usage: $0 [-h] [-p password] [-u user] [--version] dsn schema_module\n";
		print STDERR "\t-h\t\tPrint help.\n";
		print STDERR "\t-p password\tDatabase password.\n";
		print STDERR "\t-u user\t\tDatabase user.\n";
		print STDERR "\t--version\tPrint version.\n";
		print STDERR "\tdsn\t\tDatabase DSN. e.g. dbi:SQLite:dbname=ex1.db\n";
		print STDERR "\tschema_module\tName of Schema module.\n";
		return 1;
	}
	$self->{'_dsn'} = shift @ARGV;
	$self->{'_schema_module'} = shift @ARGV;

	eval "require $self->{'_schema_module'}";
	if ($EVAL_ERROR) {
		err 'Cannot load Schema module.',
			'Module name', $self->{'_schema_module'},
			'Error', $EVAL_ERROR,
		;
	}
	my $schema = eval {
		$self->{'_schema_module'}->connect($self->{'_dsn'},
			$self->{'_opts'}->{'u'}, $self->{'_opts'}->{'p'}, {});
	};
	if ($EVAL_ERROR) {
		err 'Cannot connect to Schema database.',
			'Error', $EVAL_ERROR,
		;
	}
	if (! $schema->isa('DBIx::Class::Schema')) {
		err "Instance of schema must be a 'DBIx::Class::Schema' object.",
			'Reference', $schema->isa,
		;
	}

	# Deploy.
	$schema->deploy;

	print "Schema from '$self->{'_schema_module'}' was deployed to '$self->{'_dsn'}'.\n";

	return 0;
}

1;


__END__

=pod

=encoding utf8

=head1 NAME

App::Schema::Deploy - Base class for schema-deploy script.

=head1 SYNOPSIS

 use App::Schema::Deploy;

 my $app = App::Schema::Deploy->new;
 my $exit_code = $app->run;

=head1 METHODS

=head2 C<new>

 my $app = App::Schema::Deploy->new;

Constructor.

Returns instance of object.

=head2 C<run>

 my $exit_code = $app->run;

Run.

Returns 1 for error, 0 for success.

=head1 ERRORS

 run():
         Cannot connect to Schema database.
                 Error: %s
         Cannot load Schema module.
                 Module name: %s
                 Error: %s
         Instance of schema must be a 'DBIx::Class::Schema' object.
                 Reference: %s

=head1 EXAMPLE

 use strict;
 use warnings;

 use App::Schema::Deploy;

 # Arguments.
 @ARGV = (
         'dbi:SQLite:dbname=sqlite.db',
         'Schema::Commons::Vote',
 );

 # Run.
 exit App::Schema::Deploy->new->run;

 # Output like:
 # Schema from 'Schema::Commons::Vote' was deployed to 'dbi:SQLite:dbname=ex2.db'.

=head1 DEPENDENCIES

L<English>,
L<Error::Pure>,
L<Getopt::Std>.

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/App-Schema-Deploy>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2022 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.01

=cut
