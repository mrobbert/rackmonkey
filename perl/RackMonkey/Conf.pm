package RackMonkey::Conf;
##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.2.%BUILD%                                                        #
# (C)2004-2009 Will Green (wgreen at users.sourceforge.net)                  #
# Configuration for RackMonkey                                               #
##############################################################################

use strict;
use warnings;

use Carp;

our $VERSION = '1.2.%BUILD%';
our $AUTHOR = 'Will Green (wgreen at users.sourceforge.net)';

sub new
{
	my ($className) = @_;
	my $self = 
	{
		'configpath' =>  $ENV{'RACKMONKEY_CONF'} || '/etc/rackmonkey.conf',
		'dbconnect' => '',
		'dbuser' => '',
		'dbpass' => '',
		'tmplpath' => '',
		'wwwpath' => '',
		'plugin_pdf' => 0,
		'plugin_xls' => 0,
		'defaultview' => 'rack',	
		'dateformat' => '%Y-%m-%d',	
		'shorttextlen' => 32,
		'shorturllen' => 64,
		'maxnote' => 4095,
		'maxstring' => 255,
		'maxracksize' => 255,
		'dellquery' => ''
	};
	unless (open(CONFIG, "<$$self{'configpath'}"))
	{
		croak "RMERR: Cannot open configuration file '$$self{'configpath'}': $!. You can override the configuration file path with the RACKMONKEY_CONF environment variable.";
	}
	
	while (<CONFIG>) 
	{
		chomp;
		s/^#.*//;		# comments at start of lines
		s/\s+#.*//;		# comments after whitespace	
		s/^\s+//;		# whitespace
		s/\s+$//;		# 	"	"
		next unless length;
		my ($key, $value) = m/\s*(.*?)\s*=\s*(.*)\s*/; 
		$$self{"$key"} = "$value";
	}
	
	close(CONFIG);
	
	bless $self, $className;
}

sub getConf
{
	my ($self, $key) = @_;
	confess "RM_ENGINE: '$key' is not a valid configuration parameter." unless exists $self->{"$key"};	
	return $self->{"$key"};
}