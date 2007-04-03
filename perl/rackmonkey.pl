#!/usr/bin/perl
########################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org
# Version 1.2.%BUILD%
# (C)2007 Will Green (wgreen at users.sourceforge.net)
# Main RackMonkey CGI script
########################################################################

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


# Interface TODO
# - templates should all include JS and updated 2007 header
# - decide whether to have a an </ELSE> for when no data in default views? Should at least say there are no items.
# - apply alternating colours to all default views
# - decide on form for order by foo.bar or foo_bar and be consistent
# - meta locations are considered to be buildings, hide unknown in lower locations (eg. rooms, racks etc.)? But need to include in rack view?
# - write sub to ensure no items can be put on top of each other, except in meta locations
# - decide when to use short building names, offer full name on hover
# - Drop in from column names "in room?"
# - Use proper buttons on forms everywhere


use strict;
use warnings;

use 5.006_001;

use DBI;
use CGI;
use HTML::Template;
use Time::Local;

use Data::Dumper; # For debug only

use RackMonkey::Engine;
use RackMonkey::Error;
use RackMonkey::Helper;
use RackMonkey::Conf;

our $VERSION = '1.2.%BUILD%';
our $AUTHOR = 'Will Green (wgreen at users.sourceforge.net)';

our ($template, $cgi);

$cgi = new CGI;
	
eval 
{
	my $dbh = DBI->connect(DBDCONNECT, DBUSER, DBPASS, {AutoCommit => 1, RaiseError => 1, PrintError => 0, ShowErrorStatement => 1}); 

	# Get driver version number
	my ($currentDriver) = DBDCONNECT =~ /dbi:(.*?):/;
	$currentDriver = "DBD::$currentDriver";
	my $driverVersion = eval("\$${currentDriver}::VERSION");
	
	# If using SQLite, version v1.09 or higher is required in order to support ADD COLUMN
	if (($currentDriver eq 'DBD::SQLite') && ($driverVersion < 1.09))
	{
		die "RMERR: RackMonkey requires DBD::SQLite v1.09 or higher. You are using DBD::SQLite v$driverVersion. Please consult the installation instructions.\nError occured";
	}

	my $backend = new RackMonkey::Engine($dbh);
	
	my $fullURL = $cgi->url();
	my $baseURL = $fullURL;
	$baseURL =~ s|(\w+)://([^/:]+)(:\d+)?||; # remove the domain and any port number
	
	my $view = $cgi->param('view') || 'building';
	die "View name not valid." unless $view =~/^[a-z_]+$/;
	my $id = $cgi->param('id'); # View id
	$id += 0; # force id to be numerical
	my $viewType = $cgi->param('view_type') || 'default';
	my $act =  $cgi->param('act');
	my $orderBy = $cgi->param('order_by');

	if ($act) # perform act, and return status: 303 (See Other) to redirect to a view
	{
		my $updateUser = $ENV{'REMOTE_USER'} || $ENV{'REMOTE_ADDR'};
		$act = 'update' if ($act eq 'insert');
		$backend->performAct($cgi->param('act_on'), $act, $updateUser, scalar($cgi->Vars));
		
		my $lastCreatedId = $backend->getLastInsertId;
		$id = $lastCreatedId if (!$id); # use lastCreatedId if there isn't an id
		
		my $redirectURL = "$fullURL?view=$view&view_type=$viewType";
		$redirectURL .= "&id=$id" if ($id);
		$redirectURL .= "&last_created_id=$lastCreatedId" if ($lastCreatedId);		
		print $cgi->redirect(-uri=>$redirectURL, -status=>303);
	}
	else # display a view
	{
		$template = HTML::Template->new(filename => TMPLPATH."/${view}_${viewType}.tmpl", 'die_on_bad_params' => 0, 'global_vars' => 1, 'case_sensitive' => 1, 'loop_context_vars' => 1);

		if ($view eq 'hardware')
		{
			if ($viewType =~ /^default/)
			{
				$template->param('hardware' => $backend->getHardwareList($orderBy));
			}
			else
			{
				my $selectedManufacturer = $cgi->param('last_created_id') || 0; # need to sort out this mess of CGI vars and make clearer!
	
				if (($viewType =~ /^edit/) || ($viewType =~ /^single/))
				{
					my $hardware = $backend->getHardware($id);
					$selectedManufacturer = $$hardware{'manufacturer'} if (!$selectedManufacturer); # Use database value for selected if none in CGI
					$$hardware{'support_url_short'} = shortURL($$hardware{'support_url'}); # not actually needed by edit view
					$$hardware{'spec_url_short'} = shortURL($$hardware{'spec_url'}); # not actually needed by edit view			
					$template->param($hardware);
				}
	
				if (($viewType =~ /^edit/) || ($viewType =~ /^create/))
				{
					$template->param('manufacturerlist' => $backend->getListBasicSelected('hardware_manufacturer', $selectedManufacturer));
				}
			}
		}	
		elsif ($view eq 'os')
		{
			if ($viewType =~ /^default/)
			{
				$template->param('operatingsystems' => $backend->getOsList($orderBy));
			}
			else
			{
				my $selectedManufacturer = $cgi->param('last_created_id') || 0; 
	
				if (($viewType =~ /^edit/) || ($viewType =~ /^single/))
				{
					my $operatingSystem = $backend->getOs($id);
					$template->param($operatingSystem);
					$selectedManufacturer = $$operatingSystem{'manufacturer'} if (!$selectedManufacturer); # Use database value for selected if none in CGI
				}
	
				if (($viewType =~ /^edit/) || ($viewType =~ /^create/))
				{	
					$template->param('manufacturerlist' => $backend->getListBasicSelected('software_manufacturer', $selectedManufacturer));
				}
			}		
		}
		elsif ($view eq 'org')
		{
			if ($viewType =~ /^default/)
			{
				my $orgs = $backend->getOrgList($orderBy);
				
				for my $o (@$orgs)
				{
					$$o{'descript_short'} = shortStr($$o{'descript'});
				}
				$template->param('orgs' => $orgs);
			}
			elsif (($viewType =~ /^edit/) || ($viewType =~ /^single/))
			{
				$template->param($backend->getOrg($id));
			}
			elsif ($viewType =~ /^create/)
			{
				# normalise input for boolean values
				my $customer = $cgi->param('customer') ? 1 : 0;
				my $software = $cgi->param('software') ? 1 : 0;
				my $hardware = $cgi->param('hardware') ? 1 : 0;
		
				$template->param({'customer' => $customer, 'software' => $software, 'hardware' => $hardware});
			}
		}	
		elsif ($view eq 'domain')
		{
			if ($viewType =~ /^default/)
			{
				my $domains = $backend->getDomainList($orderBy);
				for my $d (@$domains)
				{
					$$d{'descript_short'} = shortStr($$d{'descript'});
				}
				$template->param('domains' => $domains);
			}
			elsif (($viewType =~ /^edit/) || ($viewType =~ /^single/))
			{
				$template->param($backend->getDomain($id));
			}
		}		
		elsif ($view eq 'device')
		{
			if ($viewType =~ /^default/) 
			{
				my $devices = $backend->getDeviceList($orderBy);
				
				for my $d (@$devices) # calculate age of devices
				{
					$$d{'age'} = calculateAge($$d{'purchased'});
				}
				
				$template->param('devices' => $devices);
			}
			else
			{
				my $selectedHardware = $cgi->param('last_created_id') || 0; 
				my $selectedOs = $cgi->param('last_created_id') || 0; 
				my $selectedRole = $cgi->param('last_created_id') || 0; 
				my $selectedCustomer = $cgi->param('last_created_id') || 0; 
				my $selectedService = $cgi->param('last_created_id') || 0;
				my $selectedRack = $cgi->param('last_created_id') || 0; 
				

				if (($viewType =~ /^edit/) || ($viewType =~ /^single/))
				{
					my $device = $backend->getDevice($id);
					$$device{'age'} = calculateAge($$device{'purchased'});
					$template->param($device);

					if ($viewType =~ /^edit/) 
					{
						# Use database value for selected if none in CGI
						$selectedHardware = $$device{'hardware'} if (!$selectedHardware); 
						$selectedOs = $$device{'os'} if (!$selectedOs);
						$selectedRole = $$device{'role'} if (!$selectedOs);
						$selectedCustomer = $$device{'customer'} if (!$selectedCustomer);
						$selectedService = $$device{'service'} if (!$selectedService);
						$selectedRack = $$device{'rack_id'} if (!$selectedRack);
					}
				}
				if (($viewType =~ /^edit/) || ($viewType =~ /^create/))
				{
					$template->param('hardwarelist' => $backend->getListBasicSelected('hardware', $selectedHardware));
					$template->param('oslist' => $backend->getListBasicSelected('os', $selectedOs));
					$template->param('rolelist' => $backend->getListBasicSelected('role', $selectedRole));
					$template->param('customerlist' => $backend->getListBasicSelected('customer', $selectedCustomer));
					$template->param('servicelist' => $backend->getListBasicSelected('service', $selectedService));
					$template->param('racklist' => $backend->getRackListBasicSelected($selectedRack));
				}
			}
		}	
		elsif ($view eq 'role')
		{
			if ($viewType =~ /^default/)
			{
				my $roles = $backend->getRoleList($orderBy);
				
				for my $r (@$roles)
				{
					$$r{'descript_short'} = shortStr($$r{'descript'});
				}
				$template->param('roles' => $roles);
			}
			elsif (($viewType =~ /^edit/) || ($viewType =~ /^single/))
			{
				$template->param($backend->getRole($id));
			}
		}	
		elsif ($view eq 'service')
		{
			if ($viewType =~ /^default/)
			{
				my $serviceLevels = $backend->getServiceList($orderBy);
				for my $s (@$serviceLevels)
				{
					$$s{'descript_short'} = shortStr($$s{'descript'});
				}
				$template->param('services' => $serviceLevels);
			}
			elsif (($viewType =~ /^edit/) || ($viewType =~ /^single/))
			{
				$template->param($backend->getService($id));
			}
		}		
		elsif ($view eq 'building')
		{
			if ($viewType =~ /^default/)
			{
					$template->param('buildings' => $backend->getBuildingList($orderBy));
			}
			elsif (($viewType =~ /^edit/) || ($viewType =~ /^single/))
			{
				my $building = $backend->getBuilding($id);
				if ($viewType =~ /^single/)
				{
					$$building{'rooms'} = $backend->getRoomListInBuilding($id);
				}
				$template->param($building);
			}
		}
		elsif ($view eq 'room')
		{
			if ($viewType =~ /^default/)
			{
					$template->param('rooms' => $backend->getRoomList($orderBy));
			}
			else
			{
				my $selectedBuilding = $cgi->param('last_created_id') || $cgi->param('building_id') || 0;
	
				if (($viewType =~ /^edit/) || ($viewType =~ /^single/))
				{
					my $room = $backend->getRoom($id);
					$$room{'row_count'} = $backend->getRowCountInRoom($id);
					$template->param($room);
					$selectedBuilding = $$room{'building'} if (!$selectedBuilding); # Use database value for selected if none in CGI
				}
	
				if (($viewType =~ /^edit/) || ($viewType =~ /^create/))
				{	
					$template->param('buildinglist' => $backend->getListBasicSelected('building', $selectedBuilding));
				}
			}
		}
		elsif ($view eq 'row')
		{
			$template->param('rows' => $backend->getRowListInRoom($cgi->param('room_id')));
			$template->param($backend->getRoom($cgi->param('room_id')));
		}
		elsif ($view eq 'rack')
		{
			if ($viewType =~ /^default/)
			{
				$template->param('racks' => $backend->getRackList($orderBy));
			}
			elsif (($viewType =~ /^edit/) || ($viewType =~ /^single/))
			{
				my $rack = $backend->getRack($id);
				$$rack{'rack_layout'} = $backend->getRackPhysical($id) if ($viewType =~ /^physical/);
				$template->param($rack);
			}
			elsif (($viewType =~ /^physical/))
			{
				my @rackIdList = $cgi->param('rack_list');
				push (@rackIdList, $id) if (scalar(@rackIdList) == 0); # add current rack id if no list
				
				my @racks;
				for my $rackId (@rackIdList)
				{
					my $rack = $backend->getRack($rackId);
					$$rack{'rack_layout'} = $backend->getRackPhysical($rackId) if ($viewType =~ /^physical/);
					push @racks, $rack;
				}
				
				$template->param('rack_list' => \@racks);
			}	
		}		
		elsif (($view eq 'config') || ($view eq 'help') || ($view eq 'app'))
		{
			# do nothing - pages are static content
		}
		else
		{
			die "RMERR: No such view. This error should not occur, did you manually type this URL?\nError at";
		}
	}
		
	$dbh->disconnect();
	
	# Get version and date for page footer
	$template->param('version' => "$VERSION");
	my ($minute, $hour, $day, $month, $year) = (gmtime)[1, 2, 3, 4, 5];
	my $currentDate = sprintf("%04d-%02d-%02d %02d:%02d GMT", $year+1900, $month+1, $day, $hour, $minute);
	$template->param('date' => "$currentDate");

	# Support overriding the next view of the template
	$template->param('return_view' => $cgi->param('return_view'));
	$template->param('return_view_type' => $cgi->param('return_view_type'));
	$template->param('return_view_id' => $cgi->param('return_view_id'));
	
	$template->param('base_url' => $baseURL);
	$template->param('web_root' => WWWPATH);
	
	print $cgi->header();
	print $template->output;
};

if ($@)
{
	my $errMsg = $@;
	print $cgi->header();
	my $friendlyErrMsg = RackMonkey::Error::enlighten($errMsg);
	RackMonkey::Error::display($errMsg, $friendlyErrMsg);
}

