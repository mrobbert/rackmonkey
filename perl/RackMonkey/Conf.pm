package RackMonkey::Conf;
##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.2.%BUILD%                                                        #
# (C)2004-2008 Will Green (wgreen at users.sourceforge.net)                  #
# Configuration loader for RackMonkey                                        #
##############################################################################

use strict;
use warnings;

use RackMonkey::Error;

our $VERSION = '1.2.%BUILD%';
our $AUTHOR = 'Will Green (wgreen at users.sourceforge.net)';

our $conf;

# load the config file 
my $configFile = $ENV{'RACKMONKEY_CONF'} || '/etc/rackmonkey.conf';

unless (open(CONFIG, "<$configFile"))
{
	my $errMsg = "RMERR: Cannot open configuration file '$configFile': $!. You can override the configuration file path with the RACKMONKEY_CONF environment variable.";
	print "Content-type: text/html\n\n";
	my $friendlyErrMsg = RackMonkey::Error::enlighten($errMsg);
	RackMonkey::Error::display($errMsg, $friendlyErrMsg);
}

my %confHash = map 
{
  s/#.*//;		# comments
  s/^\s+//;		# whitespace
  s/\s+$//;		# 	"	"
  m/\s*(.*?)\s*=\s*(.*)\s*/; 
} <CONFIG>;

$conf = \%confHash;