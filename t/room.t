#!/usr/bin/perl
########################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org
# Version 1.2.%BUILD%
# (C)2007 Will Green (wgreen at users.sourceforge.net)
# RackMonkey Engine room unit test script
########################################################################

use strict;
use warnings;

use 5.006_001;

use DBI;

use Data::Dumper; 
use Test::Simple tests => 2;

use lib 'perl';
use RackMonkey::Engine;
use RackMonkey::Error;
use RackMonkey::Helper;

our $VERSION = '1.2.%BUILD%';
our $AUTHOR = 'Will Green (wgreen at users.sourceforge.net)';

# Database Connection Settings - should make external
use constant DBDCONNECT => 'dbi:SQLite:dbname=/tmp/rackmonkey/test.db';
use constant DBUSER => '';
use constant DBPASS => '';


my $dbh = DBI->connect(DBDCONNECT,DBUSER,DBPASS, {AutoCommit => 1, RaiseError => 1, PrintError => 0});
my $backend = new RackMonkey::Engine($dbh);
	

my $count;
eval { $count = $backend->getRoomCount(); };
ok(!$@, "calling getRoomCount");
ok(($count == 0), "no room records stored at the start of the test");


die "Buildings already exist, tests must be performed on an empty building table.\n" if ($backend->getBuildingCount() != 0);
my $newBuildingA = {'name' => 'Aldgate House', 'notes' => ''};
my $newBuildingB = {'name' => 'Barbican House', 'notes' => ''};

eval 
{
	$backend->updateBuilding(time, 'EngineTest', $newBuildingA); 
	$backend->updateBuilding(time, 'EngineTest', $newBuildingB); 
};
die "Couldn't create buildings to add rooms to. Run the building unit tests.\n" if ($@);
