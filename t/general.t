#!/usr/bin/env perl
##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.3.%BUILD%                                                        #
# (C)2004-2010 Will Green (wgreen at users.sourceforge.net)                  #
# RackMonkey Engine general methods test script                              #
##############################################################################

use strict;
use warnings;

use 5.006_001;

use Time::Local;
use Test::Simple tests => 1;

use RackMonkey::Engine;
use RackMonkey::Error;

our $VERSION = '1.3.%BUILD%';
our $AUTHOR = 'Will Green (wgreen at users.sourceforge.net)';

$ENV{'RACKMONKEY_CONF'} = 't/_rackmonkey-test.conf';

my $backend; 

eval { $backend = RackMonkey::Engine->new; };
ok(!$@, "creating engine instance $@");

