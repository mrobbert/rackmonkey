#!/usr/bin/perl
########################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org
# Version 1.2.%BUILD%
# (C)2007 Will Green (wgreen at users.sourceforge.net)
# RackMonkey Engine building unit test script
########################################################################

# Need to add tests for deleteBuildingList and for excluding meta buildings from getBuildingCount

use strict;
use warnings;

use 5.006_001;

use DBI;

use Data::Dumper; 
use Test::Simple tests => 39;

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
eval { $count = $backend->getBuildingCount(); };
ok(!$@, "calling getBuildingCount");
ok(($count == 0), "no building records stored at the start of the test");

eval { $backend->getBuilding(1); };
ok(($@ =~ /No such building id/), "retrieving non-existent building");


my $building2A;
my $id2A;
my $newBuilding2A = {'name' => 'Telehouse', 'name_short' => 'THDO', 'notes' => 'foo'};
eval { $id2A = $backend->updateBuilding(time, 'EngineTest', $newBuilding2A); };
ok(!$@, "creating new building");
eval { $building2A = $backend->getBuilding($id2A) };
ok (!$@, "calling getBuilding() on new building id");
ok ((($$building2A{'name'} eq 'Telehouse') && ($$building2A{'name_short'} eq 'THDO') && ($$building2A{'notes'} eq 'foo')), "retrieved building is correct");


eval { $backend->updateBuilding(time, 'EngineTest', $newBuilding2A); };
ok($@, "duplicate building name forbidden");


my $newBuilding3A = {'name' => '', 'notes' => 'foo'};
eval { $backend->updateBuilding(time, 'EngineTest', $newBuilding3A); };
ok($@, "empty building name forbidden");


my $newBuilding4A = {'name' => ' Hanging Gardens', 'notes' => 'foo'};
eval { $backend->updateBuilding(time, 'EngineTest', $newBuilding4A); };
ok($@, "building name beginning with space forbidden");


my ($building5A, $building5B);
my ($id5A, $id5B);
my $newBuilding5A = {'name' => 'Aardvark House', 'name_short' => 'AH', 'notes' => 'bar'};
my $newBuilding5B = {'name' => '8A&B_ .a-0', 'notes' => 'qux'};
eval 
{ 
	$id5A = $backend->updateBuilding(time, 'EngineTest', $newBuilding5A);
	$id5B = $backend->updateBuilding(time, 'EngineTest', $newBuilding5B); 
};
ok(!$@, "creation of two further buildings");
eval { $count = $backend->getBuildingCount(); };
ok(!$@, "calling getBuildingCount");
ok(($count == 3), "building record count is three");


eval
{ 
	$building5B = $backend->getBuilding($id5B);
	$building2A = $backend->getBuilding($id2A);
	$building5A = $backend->getBuilding($id5A);
};
ok(!$@, "retrieval of all three buildings");
ok((($$building2A{'name'} eq 'Telehouse') && ($$building2A{'name_short'} eq 'THDO') && ($$building2A{'notes'} eq 'foo')), "first building is correct" );
ok((($$building5A{'name'} eq 'Aardvark House')  && ($$building5A{'name_short'} eq 'AH') && ($$building5A{'notes'} eq 'bar')), "second building is correct" );
ok((($$building5B{'name'} eq '8A&B_ .a-0')  && (not defined $$building5B{'name_short'}) && ($$building5B{'notes'} eq 'qux')), "third building is correct" );

my $buildingList;
eval { $buildingList = $backend->getBuildingList(); };
ok(!$@, "calling getBuildingList() with three buildings recorded");
ok((scalar(@$buildingList) == 3), "three buildings in retrieved list");
ok(($$buildingList[0]{'name'} eq '8A&B_ .a-0'), "first building name retrieved correctly (default sort order)");
ok(($$buildingList[1]{'name'} eq 'Aardvark House'), "second building name retrieved correctly (default sort order)");
ok(($$buildingList[2]{'name'} eq 'Telehouse'), "third building name retrieved correctly (default sort order)");
ok((not defined $$buildingList[0]{'name_short'}), "first building short name retrieved correctly (default sort order)");
ok(($$buildingList[1]{'name_short'} eq 'AH'), "second building short name retrieved correctly (default sort order)");
ok(($$buildingList[2]{'name_short'} eq 'THDO'), "third building short name retrieved correctly (default sort order)");
ok(($$buildingList[0]{'notes'} eq 'qux'), "first building notes retrieved correctly (default sort order)");
ok(($$buildingList[1]{'notes'} eq 'bar'), "second building notes retrieved correctly (default sort order)");
ok(($$buildingList[2]{'notes'} eq 'foo'), "third building notes retrieved correctly (default sort order)");


eval { $backend->deleteBuilding(time, 'EngineTest', {'act_id' => $id5A}); };
ok(!$@, "deleting building by record hash");
eval { $backend->deleteBuilding(time, 'EngineTest', $id2A); };
ok(!$@, "deleting building by id");
eval { $backend->deleteBuilding(time, 'EngineTest', {'act_id' => $id5A}); };
ok($@, "error deleting non-existent building");


eval { $buildingList = $backend->getBuildingList(); };
ok(!$@, "calling getBuildingList() with one building recorded");
ok((scalar(@$buildingList) == 1), "one building in retrieved list");
ok(($$buildingList[0]{'name'} eq '8A&B_ .a-0'), "building name retrieved correctly");
ok(($$buildingList[0]{'notes'} eq 'qux'), "building notes retrieved correctly");


eval { $backend->deleteBuilding(time, 'EngineTest', $id5B); };
ok(!$@, "deleting remaining building by id");
eval { $buildingList = $backend->getBuildingList(); };
ok(!$@, "calling getBuildingList() with no buildings recorded");
ok((scalar(@$buildingList) == 0), "no buildings in retrieved list");

eval { $count = $backend->getBuildingCount(); };
ok(!$@, "calling getBuildingCount");
ok(($count == 0), "no building records stored at the end of the test");
