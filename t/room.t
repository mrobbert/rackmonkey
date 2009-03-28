#!/usr/bin/env perl
##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.2.%BUILD%                                                        #
# (C)2004-2009 Will Green (wgreen at users.sourceforge.net)                  #
# RackMonkey Engine room methods test script                                 #
##############################################################################

use strict;
use warnings;

use 5.006_001;

use Data::Dumper;
use Time::Local;
use Test::Simple tests => 4;

use RackMonkey::Engine;
use RackMonkey::Error;

our $VERSION = '1.2.%BUILD%';
our $AUTHOR = 'Will Green (wgreen at users.sourceforge.net)';

use constant META_DEFAULT => 5;

$ENV{'RACKMONKEY_CONF'} = 't/_rackmonkey-test.conf';

my $backend; 
my $count;
my $roomList;
my ($rmA, $rmIdA, $rmDataA);
my ($rmB, $rmIdB, $rmDataB);
my ($rmC, $rmIdC, $rmDataC);
my ($bdIdA, $bdIdB);

eval { $backend = RackMonkey::Engine->new; };
ok(!$@, "creating engine instance $@");
eval { $count = $backend->itemCount('room'); };
ok(!$@, "calling itemCount('room') $@");
ok(($count == 0), "no room records stored at the start of the test");
eval { $backend->room(META_DEFAULT + 1); };
ok(($@ =~ /No such room id/), "retrieving non-existent room");

die "Buildings already exist, tests must be performed on an empty building table.\n" if ($backend->itemCount('building') != 0);

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
