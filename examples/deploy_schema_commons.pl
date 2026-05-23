#!/usr/bin/env perl

use strict;
use warnings;

use App::Schema::Deploy;

# Arguments.
@ARGV = (
        'dbi:SQLite:dbname=sqlite.db',
        'Schema::Commons::Vote@0.1.0',
);

# Run.
exit App::Schema::Deploy->new->run;

# Output like:
# Schema (v0.1.0) from 'Schema::Commons::Vote' was deployed to 'dbi:SQLite:dbname=sqlite.db'.