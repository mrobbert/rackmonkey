#!/usr/bin/env perl
##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.2.%BUILD%                                                        #
# (C)2004-2007 Will Green (wgreen at users.sourceforge.net)                  #
# RackMonkey Engine building unit test script                                #
##############################################################################

# Need to add tests for excluding meta buildings from buildingCount

use strict;
use warnings;

use 5.006_001;

use DBI;

use Test::Simple tests => 40;

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
my $buildingList;
my ($bdA, $bdIdA, $bdDataA);
my ($bdB, $bdIdB, $bdDataB);
my ($bdC, $bdIdC, $bdDataC);

$bdDataA = {'name' => 'Telehouse', 'name_short' => 'THDO', 'notes' => 'foo'};
$bdDataB = {'name' => 'Aardvark House', 'name_short' => 'AH', 'notes' => 'bar'};
$bdDataC = {'name' => '8A&B_ .a-0', 'notes' => 'qux'};


eval { $count = $backend->buildingCount(); };
ok(!$@, "calling buildingCount $@");
ok(($count == 0), "no building records stored at the start of the test");

eval { $backend->building(1); };
ok(($@ =~ /No such building id/), "retrieving non-existent building");

eval { $bdIdA = $backend->updateBuilding(time, 'EngineTest', $bdDataA); };
ok(!$@, "creating new building $@");
eval { $bdA = $backend->building($bdIdA) };
ok (!$@, "calling building() on new building id $@");
ok ((($$bdA{'name'} eq $$bdDataA{'name'}) && ($$bdA{'name_short'} eq $$bdDataA{'name_short'}) && ($$bdA{'notes'} eq $$bdDataA{'notes'})), "retrieved building is correct");

eval { $backend->updateBuilding(time, 'EngineTest', $bdDataA); };
ok($@, "duplicate building name forbidden");

eval { $backend->updateBuilding(time, 'EngineTest', {'name' => '', 'notes' => 'foo'}); };
ok($@, "empty building name forbidden");

eval { $backend->updateBuilding(time, 'EngineTest', {'name' => ' Hanging Gardens', 'notes' => 'foo'}); };
ok($@, "building name beginning with space forbidden");

eval 
{ 
	$bdIdB = $backend->updateBuilding(time, 'EngineTest', $bdDataB);
	$bdIdC = $backend->updateBuilding(time, 'EngineTest', $bdDataC); 
};
ok(!$@, "creation of two further buildings");
eval { $count = $backend->buildingCount(); };
ok(!$@, "calling buildingCount $@");
ok(($count == 3), "building record count is three");

eval
{ 
	$bdC = $backend->building($bdIdC);
	$bdA = $backend->building($bdIdA);
	$bdB = $backend->building($bdIdB);
};
ok(!$@, "retrieval of all three buildings $@");
ok((($$bdA{'name'} eq $$bdDataA{'name'}) && ($$bdA{'name_short'} eq $$bdDataA{'name_short'}) && ($$bdA{'notes'} eq $$bdDataA{'notes'})), "first building is correct" );
ok((($$bdB{'name'} eq $$bdDataB{'name'}) && ($$bdB{'name_short'} eq $$bdDataB{'name_short'}) && ($$bdB{'notes'} eq $$bdDataB{'notes'})), "second building is correct" );
ok((($$bdC{'name'} eq $$bdDataC{'name'}) && not defined $$bdC{'name_short'} && ($$bdC{'notes'} eq $$bdDataC{'notes'})), "third building is correct" );

eval { $buildingList = $backend->buildingList(); };
ok(!$@, "calling buildingList() with three buildings recorded $@");
ok((scalar(@$buildingList) == 3), "three buildings in retrieved list");
ok(($$buildingList[0]{'name'} eq $$bdDataC{'name'}), "first building name retrieved correctly (default sort order)");
ok(($$buildingList[1]{'name'} eq $$bdDataB{'name'}), "second building name retrieved correctly (default sort order)");
ok(($$buildingList[2]{'name'} eq $$bdDataA{'name'}), "third building name retrieved correctly (default sort order)");
ok((not defined $$buildingList[0]{'name_short'}), "first building short name retrieved correctly (default sort order)");
ok(($$buildingList[1]{'name_short'} eq $$bdB{'name_short'}), "second building short name retrieved correctly (default sort order)");
ok(($$buildingList[2]{'name_short'} eq $$bdA{'name_short'}), "third building short name retrieved correctly (default sort order)");
ok(($$buildingList[0]{'notes'} eq $$bdDataC{'notes'}), "first building notes retrieved correctly (default sort order)");
ok(($$buildingList[1]{'notes'} eq $$bdDataB{'notes'}), "second building notes retrieved correctly (default sort order)");
ok(($$buildingList[2]{'notes'} eq $$bdDataA{'notes'}), "third building notes retrieved correctly (default sort order)");

eval { $backend->deleteBuilding(time, 'EngineTest', $bdB); };
ok(!$@, "deleting building by record hash $@");
eval { $backend->deleteBuilding(time, 'EngineTest', $bdIdA); };
ok(!$@, "deleting building by id $@");
eval { $backend->deleteBuilding(time, 'EngineTest', $bdB); };
ok($@, "error deleting non-existent building");

eval { $buildingList = $backend->buildingList(); };
ok(!$@, "calling buildingList() with one building recorded $@");
ok((scalar(@$buildingList) == 1), "one building in retrieved list");
ok(($$buildingList[0]{'name'} eq $$bdDataC{'name'}), "building name retrieved correctly");
ok((not defined $$buildingList[0]{'name_short'}), "building short name retrieved correctly");
ok(($$buildingList[0]{'notes'} eq $$bdDataC{'notes'}), "building notes retrieved correctly");

eval { $backend->deleteBuilding(time, 'EngineTest', $bdIdC); };
ok(!$@, "deleting remaining building by id $@");
eval { $buildingList = $backend->buildingList(); };
ok(!$@, "calling buildingList() with no buildings recorded $@");
ok((scalar(@$buildingList) == 0), "no buildings in retrieved list");

eval { $count = $backend->buildingCount(); };
ok(!$@, "calling buildingCount $@");
ok(($count == 0), "no building records stored at the end of the test");
