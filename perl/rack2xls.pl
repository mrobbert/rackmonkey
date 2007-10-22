#!/usr/bin/env perl
##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.2.%BUILD%                                                        #
# (C)2004-2007 Will Green (wgreen at users.sourceforge.net)                  #
# RackMonkey XLS Spreadsheet Export Script                                   #
##############################################################################

# Portions of this code contributed by Pierre Larsson, (C)2007 Pierre Larsson

# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.

# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.

# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

use strict;
use warnings;

use 5.006_001;

use Data::Dumper; # for debug only - comment out from release versions

use DBI;
use Time::Local;
use Spreadsheet::WriteExcel;

use RackMonkey::CGI;
use RackMonkey::Engine;
use RackMonkey::Error;
use RackMonkey::Helper;
use RackMonkey::Conf;

our $VERSION = '1.2.%BUILD%';
our $AUTHOR = 'Will Green (wgreen at users.sourceforge.net)';

our ($template, $cgi);

$cgi = new RackMonkey::CGI;
	
eval 
{
	my $dbh = DBI->connect(DBDCONNECT, DBUSER, DBPASS, {AutoCommit => 1, RaiseError => 1, PrintError => 0, ShowErrorStatement => 1}); 
	checkSupportedDriver();
	my $backend = new RackMonkey::Engine($dbh);

	my $fullURL = $cgi->url;
	my $baseURL = $cgi->baseUrl;
	my $view = $cgi->view;
	my $id = $cgi->viewId;
	my $viewType = $cgi->viewType;
	my $act =  $cgi->act;
	my $orderBy = $cgi->orderBy;
	my $filterBy = $cgi->filterBy;

	# Export rack physical view
	
	if (($view eq 'rack') && ($viewType =~ /^xls_export/))
	{
		my @rackIdList = $cgi->rackList;
		push (@rackIdList, $id) if (scalar(@rackIdList) == 0); # add current rack id if no list
		die "RMERR: You need to select at least one rack to display.\nError occured" unless $rackIdList[0];
		my @racks;
		for my $rackId (@rackIdList)
		{
			my $rack = $backend->rack($rackId);
			$$rack{'rack_layout'} = $backend->rackPhysical($rackId, $cgi->id('device'));
 			push @racks, $rack;
		}

		print "Content-type: application/vnd.ms-excel\n";
		print "Content-Disposition: attachment; filename=rack.xls\n\n";

		# Create a new Excel workbook
		my $workbook = Spreadsheet::WriteExcel->new("-");

		# Add a worksheet
		my $worksheet = $workbook->addworksheet();

		# Add custom colors
		my $lightblue = $workbook->set_custom_color(40, '#6699FF');

		#  Add and define default format
		my $format = $workbook->addformat(); # Add a format
		$format->set_font('Arial');
		$format->set_size(10);
		$format->set_border(1);

		my $textwrap_format = $workbook->addformat(); # Add textwrap format
		$textwrap_format->copy($format);
		$textwrap_format->set_text_wrap();

		$format->set_align('center');

		#  Add and define url format
		my $url_format = $workbook->addformat(); # Add a format
		$url_format->set_font('Arial');
		$url_format->set_size(10);
		$url_format->set_align('center');
		$url_format->set_underline();
		$url_format->set_border(1);

		#  Add and define headers format
		my $headers_format = $workbook->addformat(); # Add a format
		$headers_format->set_font('Arial');
		$headers_format->set_size(12);
		$headers_format->set_align('center');
		$headers_format->set_bold();
		$headers_format->set_bg_color($lightblue);
		$headers_format->set_border(1);

		my $product_header = $workbook->addformat(
			border  => 5,
			valign  => 'vcenter',
			align   => 'center',
			font    => 'Arial',
			size  => 15,
			bold  => 3,
			bg_color  => 'grey',
		);
								      
		my $col = 0;
		my $row = 2;
		$worksheet->set_column(1 , 1 , 15);
		$worksheet->set_column(2, 2 , 30);
		$worksheet->set_column(5, 5 , 15);
		$worksheet->set_column(6, 6 , 25);
		$worksheet->set_column(7, 7 , 10);
		$worksheet->set_column(8, 8 , 12);
		$worksheet->set_column(9, 9 , 12);
		$worksheet->set_column(10, 10 , 50);

		foreach my $rack(@racks)
		{
			foreach my $rack_layout(@{$rack->{rack_layout}})
			{
				$worksheet->write($row, $col, $rack_layout->{rack_pos}, $format);
				$worksheet->write($row, $col+1, $rack_layout->{name}, $format);
				$row++
			}
		}
		
		my ($minute, $hour, $day, $month, $year) = (gmtime)[1, 2, 3, 4, 5];
		my $currentDate = sprintf("%04d-%02d-%02d %02d:%02d GMT", $year+1900, $month+1, $day, $hour, $minute);
		
		my $footerFormat = $workbook->addformat(
			valign  => 'vcenter',
			align   => 'left',
			font    => 'Verdana',
			size  => 9,
			bold  => 3
		);
		$worksheet->write($row+2, 0, "Generated by RackMonkey v$VERSION on $currentDate", $footerFormat);
	}
	elsif (($view eq 'device') && ($viewType =~ /^xls_export/))
	{
		# we don't yet support exporting the device table
		die "RM2XLS: Not yet supported. Error at"
	}
	else
	{
		die "RM2XLS: Not a valid view for rack2xls. Error at"
	}
};
if ($@)
{
	my $errMsg = $@;
	print $cgi->header;
	my $friendlyErrMsg = RackMonkey::Error::enlighten($errMsg);
	RackMonkey::Error::display($errMsg, $friendlyErrMsg);
}