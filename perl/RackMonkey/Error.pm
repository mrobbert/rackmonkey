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
	
	
	# foreign key constraints - should ensure there is one of these for each foreign key constraint and they work on all DB
	if ($errStr =~ /fkd_hardware_manufacturer_id/)
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
	if ($errStr =~ /fkd_os_manufacturer_id/)
	{
		$newErrStr = "Couldn't delete that organisation.\nIt's listed as a manufacturer for one or more operating systems.";
	}
	
	if ($errStr =~ /fkd_room_building_id/)
	{
		$newErrStr = "Couldn't delete that building.\nIt contains one or more rooms.";
	}
	
	# uniqueness errors - should ensure there is one of these for each unique index and they work on all DB
	if ($errStr =~ /columns name, building are not unique/)
	{
		$newErrStr = "A room with this name already exists in this building.\nPlease choose another name."
	}
	
	# validation errors
	elsif ($errStr =~ /column name is not unique/)
	{
		$newErrStr = "Couldn't create new entry.\nAn entry of that type with that name already exists, please choose another name.";
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
		Use the back button to go back to the previous page and correct the problem.<br />
		Or return to <a href="./rackmonkey.pl">RackMonkey home</a>.
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
