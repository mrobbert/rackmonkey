#!/usr/bin/env perl
##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.2.%BUILD%                                                        #
# (C)2004-2009 Will Green (wgreen at users.sourceforge.net)                  #
# RackMonkey XLS Spreadsheet Export Script                                   #
##############################################################################

# Portions of this code contributed by Pierre Larsson,
#	(C)2007-2008 Pierre Larsson

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

use DBI;
use Time::Local;
use Spreadsheet::WriteExcel;

use Data::Dumper;

use RackMonkey::CGI;
use RackMonkey::Engine;
use RackMonkey::Error;
use RackMonkey::Conf;

our $VERSION = '1.2.%BUILD%';
our $AUTHOR  = 'Will Green (wgreen at users.sourceforge.net)';

our ($template, $cgi, $conf, $backend);

$cgi = new RackMonkey::CGI;

my $rack_layout;
eval {
    $backend = RackMonkey::Engine->new;
    $conf    = $$backend{'conf'};

    my $fullURL      = $cgi->url;
    my $baseURL      = $cgi->baseUrl;
    my $view         = $cgi->view($$conf{'defaultview'});
    my $id           = $cgi->viewId;
    my $viewType     = $cgi->viewType;
    my $act          = $cgi->act;
    my $filterBy     = $cgi->filterBy;
    my $deviceSearch = $cgi->deviceSearch;
    my $orderBy      = $cgi->orderBy;
    my $loggedInUser = $ENV{'REMOTE_USER'} || $ENV{'REMOTE_ADDR'};

    # Export rack physical view
    if (($view eq 'rack') && ($viewType =~ /^xls_export/))
    {
        my @rackIdList = $cgi->rackList;
        push(@rackIdList, $id) if (scalar(@rackIdList) == 0);    # add current rack id if no list
        die "RMERR: You need to select at least one rack to display." unless $rackIdList[0];
        my @racks;
        for my $rackId (@rackIdList)
        {
            my $rack = $backend->rack($rackId);
            $$rack{'rack_layout'} = $backend->rackPhysical($rackId, $cgi->id('device'));
            push @racks, $rack;
        }

        print "Content-type: application/vnd.ms-excel\n";
        print "Content-Disposition: attachment; filename=rack.xls\n\n";

        # Create a new workbook
        my $workbook = Spreadsheet::WriteExcel->new("-");

        # Add a worksheet and set formats
        my $worksheet = $workbook->addworksheet();
        my ($format, $headers_format, $footerFormat, $url_format) = formatSpreadsheet($workbook);

        # create the headers and set the column widths
        $worksheet->write(0, 0,  "Device",        $headers_format);
        $worksheet->write(0, 1,  "Rack",          $headers_format);
        $worksheet->write(0, 2,  "Room",          $headers_format);
        $worksheet->write(0, 3,  "Role",          $headers_format);
        $worksheet->write(0, 4,  "Hardware",      $headers_format);
        $worksheet->write(0, 5,  "Size (U)",      $headers_format);
        $worksheet->write(0, 6,  "OS",            $headers_format);
        $worksheet->write(0, 7,  "Serial",        $headers_format);
        $worksheet->write(0, 8,  "Asset",         $headers_format);
        $worksheet->write(0, 9,  "Customer",      $headers_format);
        $worksheet->write(0, 10, "Service Level", $headers_format);

        $worksheet->set_column(0,  0,  15);
        $worksheet->set_column(1,  1,  15);
        $worksheet->set_column(2,  2,  30);
        $worksheet->set_column(5,  5,  15);
        $worksheet->set_column(6,  6,  25);
        $worksheet->set_column(7,  7,  10);
        $worksheet->set_column(8,  8,  12);
        $worksheet->set_column(9,  9,  12);
        $worksheet->set_column(10, 10, 50);

        # start writing data in the first column and below the header
        my $col = 0;
        my $row = 1;

        foreach my $rack (@racks)
        {
            my $last_name = '';
            for my $rack_layout (@{$rack->{'rack_layout'}})
            {
                if ($rack_layout->{'name'} ne $last_name)
                {
                    if ($rack_layout->{'name'})
                    {
                        my $device = $backend->device($rack_layout->{'id'});

                        $worksheet->write($row, $col,     $device->{'name'},                                  $format);
                        $worksheet->write($row, $col + 1, "$device->{rack_name} [$device->{rack_pos}]",       $format);
                        $worksheet->write($row, $col + 2, "$device->{room_name} in $device->{building_name}", $format);

                        if ($rack_layout->{'role'})
                        {
                            $worksheet->write($row, $col + 3, $backend->role($rack_layout->{'role'})->{'name'}, $format);
                        }
                        else
                        {
                            $worksheet->write($row, $col + 3, "", $format);
                        }

                        $worksheet->write($row, $col + 4, $rack_layout->{'hardware_name'}, $format);
                        $worksheet->write($row, $col + 5, $rack_layout->{'hardware_size'}, $format);

                        if ($device->{'os_name'})
                        {
                            $worksheet->write($row, $col + 6, $device->{'os_name'}, $format);
                        }
                        else
                        {
                            $worksheet->write($row, $col + 6, "", $format);
                        }

                        if ($device->{'serial_no'})
                        {
                            $worksheet->write($row, $col + 7, $device->{'serial_no'}, $format);
                        }
                        else
                        {
                            $worksheet->write($row, $col + 7, "-", $format);
                        }

                        if ($device->{'asset_no'})
                        {
                            $worksheet->write($row, $col + 8, $device->{'asset_no'}, $format);
                        }
                        else
                        {
                            $worksheet->write($row, $col + 8, "-", $format);
                        }

                        $worksheet->write($row, $col + 9,  $device->{'customer_name'}, $format);
                        $worksheet->write($row, $col + 10, $device->{'service_name'},  $format);
                        $last_name = $device->{'name'};
                        $row++;
                    }
                }
            }
        }
        $worksheet->set_column('A:K', 20);

        my $merge_format = $workbook->add_format(
            'border' => 6,
            'valign' => 'vcenter',
            'align'  => 'center',
        );

        #$worksheet->merge_range('B3:D4', 'Vertical and horizontal', $merge_format);

        my ($minute, $hour, $day, $month, $year) = (gmtime)[1, 2, 3, 4, 5];
        my $currentDate = sprintf("%04d-%02d-%02d %02d:%02d GMT", $year + 1900, $month + 1, $day, $hour, $minute);
        $worksheet->write($row + 2, 0, "Generated by RackMonkey v$VERSION on $currentDate", $footerFormat);
    }
    elsif (($view eq 'device') && ($viewType =~ /^xls_export/))
    {
        print "Content-type: application/vnd.ms-excel\n";
        print "Content-Disposition: attachment; filename=devicelist.xls\n\n";

        # Create a new workbook
        my $workbook = Spreadsheet::WriteExcel->new("-");

        # Add a worksheet and set formats
        my $worksheet = $workbook->addworksheet();
        my ($format, $headers_format, $footerFormat, $url_format) = formatSpreadsheet($workbook);

        # create the headers and set the column widths
        $worksheet->write(0, 0,  "Device",        $headers_format);
        $worksheet->write(0, 1,  "Domain",        $headers_format);
        $worksheet->write(0, 2,  "In Service",    $headers_format);
        $worksheet->write(0, 3,  "Status",        $headers_format);
        $worksheet->write(0, 4,  "Position",      $headers_format);
        $worksheet->write(0, 5,  "Rack",          $headers_format);
        $worksheet->write(0, 6,  "Room",          $headers_format);
        $worksheet->write(0, 7,  "Building",      $headers_format);
        $worksheet->write(0, 8,  "Role",          $headers_format);
        $worksheet->write(0, 9,  "Manufacturer",  $headers_format);
        $worksheet->write(0, 10, "Hardware",      $headers_format);
        $worksheet->write(0, 11, "Size (U)",      $headers_format);
        $worksheet->write(0, 12, "OS",            $headers_format);
        $worksheet->write(0, 13, "Serial",        $headers_format);
        $worksheet->write(0, 14, "Asset",         $headers_format);
        $worksheet->write(0, 15, "Customer",      $headers_format);
        $worksheet->write(0, 16, "Service Level", $headers_format);
        $worksheet->write(0, 17, "Notes",         $headers_format);

        $worksheet->set_column(0,  0,  18);
        $worksheet->set_column(1,  1,  30);
        $worksheet->set_column(2,  2,  12);
        $worksheet->set_column(3,  3,  16);
        $worksheet->set_column(4,  5,  9);
        $worksheet->set_column(6,  6,  12);
        $worksheet->set_column(7,  7,  20);
        $worksheet->set_column(8,  8,  18);
        $worksheet->set_column(9,  9,  16);
        $worksheet->set_column(10, 10, 20);
        $worksheet->set_column(11, 11, 12);
        $worksheet->set_column(12, 14, 16);
        $worksheet->set_column(15, 15, 20);
        $worksheet->set_column(16, 16, 22);
        $worksheet->set_column(17, 17, 50);

        # start writing data in the first column and below the header
        my $col = 0;
        my $row = 1;

        my $devices = $backend->deviceList;
        for my $device (@$devices)
        {
            $worksheet->write($row, $col++, $device->{'name'}, $format);

            if ($device->{'domain'})
            {
                $worksheet->write($row, $col++, $device->{'domain_name'}, $format);
            }
            else
            {
                $worksheet->write($row, $col++, '-', $format);
            }

            if ($device->{'in_service'})
            {
                $worksheet->write($row, $col++, 'Yes', $format);
            }
            else
            {
                $worksheet->write($row, $col++, 'No', $format);
            }

            if ($device->{'building_meta_default_data'})
            {
                $worksheet->write($row, $col++, $device->{'building_name'}, $format);
                $worksheet->write($row, $col++, '-',                        $format);
                $worksheet->write($row, $col++, '-',                        $format);
                $worksheet->write($row, $col++, '-',                        $format);
                $worksheet->write($row, $col++, '-',                        $format);
            }
            else
            {
                $worksheet->write($row, $col++, 'racked',                   $format);
                $worksheet->write($row, $col++, $device->{'rack_pos'},      $format);
                $worksheet->write($row, $col++, $device->{'rack_name'},     $format);
                $worksheet->write($row, $col++, $device->{'room_name'},     $format);
                $worksheet->write($row, $col++, $device->{'building_name'}, $format);
            }

            $worksheet->write($row, $col++, $device->{'role_name'},                  $format);
            $worksheet->write($row, $col++, $device->{'hardware_manufacturer_name'}, $format);
            $worksheet->write($row, $col++, $device->{'hardware_name'},              $format);
            $worksheet->write($row, $col++, $device->{'hardware_size'},              $format);
            $worksheet->write($row, $col++, $device->{'os_name'},                    $format);

            if ($device->{'serial_no'})
            {
                $worksheet->write($row, $col++, $device->{'serial_no'}, $format);
            }
            else
            {
                $worksheet->write($row, $col++, '-', $format);
            }

            if ($device->{'asset_no'})
            {
                $worksheet->write($row, $col++, $device->{'asset_no'}, $format);
            }
            else
            {
                $worksheet->write($row, $col++, '-', $format);
            }

            $worksheet->write($row, $col++, $device->{'customer_name'},      $format);
            $worksheet->write($row, $col++, $device->{'service_name'},       $format);
            $worksheet->write($row, $col++, formatNotes($device->{'notes'}), $format);

            $row++;
            $col = 0;
        }

        my ($minute, $hour, $day, $month, $year) = (gmtime)[1, 2, 3, 4, 5];
        my $currentDate = sprintf("%04d-%02d-%02d %02d:%02d GMT", $year + 1900, $month + 1, $day, $hour, $minute);
        $worksheet->write($row + 2, 0, "Generated by RackMonkey v$VERSION on $currentDate", $footerFormat);

    }
    else
    {
        die "RM2XLS: Not a valid view for rack2xls.";
    }
};
if ($@)
{
    my $errMsg = $@;
    print $cgi->header;
    my $friendlyErrMsg = RackMonkey::Error::enlighten($errMsg);
    RackMonkey::Error::display($errMsg, $friendlyErrMsg);
}

sub formatSpreadsheet
{
    my $workbook = shift;

    # Add custom colors
    my $grey = $workbook->set_custom_color(40, '#282828');

    # Add and define default format
    my $format = $workbook->addformat(
        'font' => 'Verdana',
        'size' => 10
    );

    my $textwrap_format = $workbook->addformat();
    $textwrap_format->copy($format);
    $textwrap_format->set_text_wrap();

    $format->set_align('left');

    # Add and define url format
    my $url_format = $workbook->addformat();
    $url_format->set_font('Arial');
    $url_format->set_size(10);
    $url_format->set_align('left');
    $url_format->set_underline();

    # Add and define headers format
    my $headers_format = $workbook->addformat();
    $headers_format->set_font('Verdana');
    $headers_format->set_size(12);
    $headers_format->set_align('left');
    $headers_format->set_bg_color($grey);
    $headers_format->set_color('white');

    my $product_header = $workbook->addformat(
        'border'   => 5,
        'valign'   => 'vcenter',
        'align'    => 'left',
        'font'     => 'Arial',
        'size'     => 15,
        'bold'     => 3,
        'bg_color' => 'grey',
    );

    my $footerFormat = $workbook->addformat(
        'valign' => 'vcenter',
        'align'  => 'left',
        'font'   => 'Verdana',
        'size'   => 9,
        'bold'   => 3,
        'italic' => 1
    );

    return ($format, $headers_format, $footerFormat, $url_format);
}

# We can't have multiple formats in once cell so we have to strip formatting from notes
sub formatNotes
{
    my $note = shift;

    $note =~ s/\[(.*?)\|(.*?)\]/$2 ($1)/sg;    # format URLs
    $note =~ s/\*\*\*(.*?)\*\*\*/$1/sg;        # strip strong using ***
    $note =~ s/\*\*(.*?)\*\*/$1/sg;            # strip emphasis using **
    return $note;
}
