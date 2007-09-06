package RackMonkey::Error;
########################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org
# Version 1.2.%BUILD%
# (C)2007 Will Green (wgreen at users.sourceforge.net)
# Error handling functions for RackMonkey
########################################################################

use strict;
use warnings;

our $VERSION = '1.2.%BUILD%';
our $AUTHOR = 'Will Green (wgreen at users.sourceforge.net)';

sub enlighten
{
	my $errStr = shift;
	my $newErrStr = "An error occured.";
	
	# DBI Connection errors
	if ($errStr =~ /^DBI connect/)
	{
		$newErrStr = "Couldn't connect to RackMonkey database.\nCheck your database is available and that your configuration file is correct.";
	}
	elsif ($errStr =~ /attempt to write a readonly database/)
	{
		$newErrStr = "Couldn't write to the RackMonkey database.\nCheck the permissions on the database file or see the install document."
	}
	
	# foreign key constraints - should ensure there is one of these for each foreign key constraint and they work on all DB
	elsif ($errStr =~ /fkd_hardware_manufacturer_id/)
	{
		$newErrStr = "Couldn't delete that organisation.\nIt's listed as a manufacturer for one or more pieces of hardware.";
	}
	elsif ($errStr =~ /fk[iu]_hardware_manufacturer_id/)
	{
		$newErrStr = "Couldn't create hardware entry.\nYou need to choose a manufacturer for this operating system.";
	}
	elsif ($errStr =~ /fk[iu]_os_manufacturer_id/)
	{
		$newErrStr = "Couldn't create operating system entry.\nYou need to choose a manufacturer for this operating system.";
	}
	elsif ($errStr =~ /fkd_os_manufacturer_id/)
	{
		$newErrStr = "Couldn't delete that organisation.\nIt's listed as a manufacturer for one or more operating systems.";
	}
	elsif ($errStr =~ /fkd_room_building_id/)
	{
		$newErrStr = "Couldn't delete that building.\nIt contains one or more rooms.";
	}
	
	# validation errors
	elsif ($errStr =~ /columns? (.*?) (?:is|are) not unique/)
	{
		$newErrStr = "Couldn't create entry.\nAn entry of that type with that $1 already exists, please choose another.";
	}
	
	# template errors
	elsif ($errStr =~ /HTML::Template->new\(\) : Cannot open included file (.+tmpl)/)
	{
		$newErrStr = "Couldn't open template $1.\nCheck the template path specified in the config.";
	}
	
	# General RackMonkey errors
	elsif ($errStr =~ /RMERR:(.*)/)
	{
		$newErrStr = "$1";
	}
	
	# General RackMonkey errors
	elsif ($errStr =~ /RM2XLS:(.*)/)
	{
		$newErrStr = "$1";
	}
	
	return $newErrStr;	
}


sub display # nasty embedded HTML, need to fix
{
	my ($errMsg, $friendlyErrMsg) = @_;
	
	$errMsg =~ s/\n/\n\t\t<br\/>/gm; # replace newlines with <br> for HTML	
	$friendlyErrMsg =~ s/\n/\n\t\t<br\/>/gm; # replace newlines with <br> for HTML

	print <<END;
	<?xml version="1.0"?>
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
		<head>
			<title>RackMonkey Error</title>
		</head>
		<body style='font-family:sans-serif'>
		<hr/>
		<p><strong style='color: maroon'>RackMonkey Error</strong></p>
		<p>
		$friendlyErrMsg
		</p>
		
		<p><strong>To Continue, either:</strong><br />
		Use the web browser back button to return to the previous page and correct the problem.<br />
		Or go to <a href="./rackmonkey.pl">RackMonkey home</a>.
		</p>
		<hr/>
		<p style='font-size: small'>
		<strong>Error Details</strong><br/>
		$errMsg
		</p>
		<p style='font-size: small'>
			If you believe this is a bug, send this entire message, and a record of what you did, to the
			<a href='http://www.rackmonkey.org'>RackMonkey developers</a>.
		</p>
		</body>
	</html>
END
	exit;
}

1;
