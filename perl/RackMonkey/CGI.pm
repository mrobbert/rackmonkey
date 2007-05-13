package RackMonkey::CGI;
##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.2.%BUILD%                                                        #
# (C)2007 Will Green (wgreen at users.sourceforge.net)                       #
# CGI Support for Rackmonkey                                                 #
##############################################################################

use strict;
use warnings;

use 5.006_001;

use CGI;
use Data::Dumper; # For debug only

use RackMonkey::Conf;
use RackMonkey::Helper;

our $VERSION = '1.2.%BUILD%';
our $AUTHOR = 'Will Green (wgreen at users.sourceforge.net)';

##############################################################################
# Common Methods                                                             #
##############################################################################

sub new
{
	my ($className) = @_;
	my $self = {'cgi' => new CGI};
	bless $self, $className;
}

sub cgi
{
	my $self = shift;
	$self->{'cgi'};
}

sub view
{
	my $self = shift;
	my $view = $self->cgi->param('view') || '';
	$view = DEFAULTVIEW unless $view =~/^[a-z_]+$/;
	return $view;
}

sub viewType
{
	my $self = shift;
	my $viewType = $self->cgi->param('view_type');
	$viewType = 'default' unless $viewType;
}

sub url
{
	my $self = shift;
	return $self->cgi->url;	
}

sub baseUrl
{
	my $self = shift;
	my $url = $self->cgi->url;
	$url =~ s|(\w+)://([^/:]+)(:\d+)?||; # remove the domain and any port number
	return $url;
}

sub viewId
{
	my $self = shift;
	my $id = $self->cgi->param('id');
	$id += 0;
	return $id;
}

sub actId
{
	my $self = shift;
	my $id = $self->cgi->param('act_id');
	$id += 0;
	return $id;	
}

sub act
{
	my $self = shift;
	return $self->cgi->param('act');	
}

sub actOn
{
	my $self = shift;
	$self->cgi->param('act_on');
}

sub orderBy
{
	my $self = shift;
	return $self->cgi->param('order_by');	
}

sub redirect303
{
	my ($self, $redirectUrl) = @_;
	print $self->cgi->redirect(-uri=>$redirectUrl, -status=>303);
}

sub vars
{
	my $self = shift;
	return $self->cgi->Vars;
}

sub header
{
	my $self = shift;
	return $self->cgi->header;
}

sub lastCreatedId
{
	my $self = shift;
	my $id = $self->cgi->param('last_created_id');
	$id += 0;
	return $id;
}

sub returnView
{
	my $self = shift;
	return $self->cgi->param('return_view');
}

sub returnViewType
{
	my $self = shift;
	return $self->cgi->param('return_view_type');
}

sub returnViewId
{
	my $self = shift;
	my $id = $self->cgi->param('return_view_id');
	$id += 0;
	return $id;
}

sub customer
{
	my $self = shift;
	return $self->cgi->param('customer') ? 1 : 0;	
}

sub software
{
	my $self = shift;
	return $self->cgi->param('software') ? 1 : 0;	
}

sub hardware
{
	my $self = shift;
	return $self->cgi->param('hardware') ? 1 : 0;	
}

sub buildingId
{
	my $self = shift;
	my $id = $self->cgi->param('building_id');	
	$id += 0;
	return $id;
}

sub roomId
{
	my $self = shift;
	my $id = $self->cgi->param('room_id');	
	$id += 0;
	return $id;
}

sub rackList
{
	my $self = shift;
	return $self->cgi->param('rack_list');
}

##############################################################################
# Select List Methods                                                        #
##############################################################################

sub selectItem
{
	my ($self, $items, $selectedId) = @_;
	$selectedId = $selectedId || 0;

	for my $i (@$items)
	{
		$$i{'selected'} = ($$i{'id'} == $selectedId); # choose selected item
		$$i{'name'} = '- '.$$i{'name'} if ($$i{'meta_default_data'}); # prefix name with - if it's meta
	}		
	return $items;	
}

sub selectRoom
{
	my ($self, $items, $selectedId) = @_;
	$items = $self->selectItem($items, $selectedId);

	for my $i (@$items)
	{
		$$i{'name'} = $$i{'name'}.' in '.$$i{'building_name'} unless $$i{'meta_default_data'};
	}
	return $items;
}

sub selectRack
{
	my ($self, $items, $selectedId) = @_;
	$items = $self->selectItem($items, $selectedId);

	for my $i (@$items)
	{
		$$i{'name'} = $$i{'name'}.' in '.$$i{'room_name'}.' in '.$$i{'building_name'} unless $$i{'meta_default_data'};
	}
	return $items;
}

sub selectHardware
{
	my ($self, $items, $selectedId) = @_;
	$items = $self->selectItem($items, $selectedId);

	for my $i (@$items)
	{
		$$i{'name'} = $$i{'manufacturer_name'}.' '.$$i{'name'} unless $$i{'meta_default_data'};
	}
	return $items;
}