#!/usr/bin/env perl
##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.2.%BUILD%                                                        #
# (C)2004-2007 Will Green (wgreen at users.sourceforge.net)                  #
# RackMonkey Engine room unit test script                                   #
##############################################################################

use strict;
use warnings;

use 5.006_001;

use DBI;

use Test::Simple tests => 3;

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
my $roomList;
my ($rmA, $rmIdA, $rmDataA);
my ($rmB, $rmIdB, $rmDataB);
my ($rmC, $rmIdC, $rmDataC);
my ($bdIdA, $bdIdB);



eval { $count = $backend->roomCount(); };
ok(!$@, "calling roomCount $@");
ok(($count == 0), "no room records stored at the start of the test");
eval { $backend->room(1); };
ok(($@ =~ /No such room id/), "retrieving non-existent room");

die "Buildings already exist, tests must be performed on an empty building table.\n" if ($backend->buildingCount() != 0);

eval 
{
	$bdIdA = $backend->updateBuilding(time, 'EngineTest', {'name' => 'Aldgate House'}); 
	$bdIdB = $backend->updateBuilding(time, 'EngineTest', {'name' => 'Barbican House'}); 
};
die "Couldn't create buildings to add rooms to - $@" if ($@);



eval 
{
	$backend->deleteBuilding(time, 'EngineTest', $bdIdA); 
	$backend->deleteBuilding(time, 'EngineTest', $bdIdB); 
};
die "Couldn't delete buildings - $@\n" if ($@);
