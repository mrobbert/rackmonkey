package RackMonkey::CGI;
##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.2.%BUILD%                                                        #
# (C)2004-2008 Will Green (wgreen at users.sourceforge.net)                  #
# CGI Support for Rackmonkey                                                 #
##############################################################################

use strict;
use warnings;

use 5.006_001;

use CGI;

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

sub referer 
{
	my $self = shift;
	return $self->cgi->referer;
}

sub view
{
	my ($self, $defaultView) = @_;
	$defaultView ||= 'rack';
	my $view = $self->cgi->param('view') || '';
	$view = $defaultView unless $view =~/^[a-z_]+$/;
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

sub hideDomain
{
	my $self = shift;
	return $self->cgi->param('hide_domain');	
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
	my $orderBy = $self->cgi->param('order_by') || '';
	return $orderBy;	
}

sub priorOrderBy
{
	my $self = shift;
	my $priorCGI = new CGI($self->referer);
	return $priorCGI->param('order_by');
}

sub filterString
{
	my $self = shift;
	my $customer = ($self->cgi->param('filter_device_customer') || 0) + 0;
	my $role = ($self->cgi->param('filter_device_role') || 0) + 0;
	my $hardware = ($self->cgi->param('filter_device_hardware') || 0) + 0;
	my $os = ($self->cgi->param('filter_device_os') || 0) + 0;
	
	return "filter_device_customer=$customer&amp;filter_device_role=$role&amp;filter_device_hardware=$hardware&amp;filter_device_os=$os";
}

sub filterBy
{
	my $self = shift;
	my %filters;
	
	$filters{'device.customer'} = $self->cgi->param('filter_device_customer') if ($self->cgi->param('filter_device_customer'));	
	$filters{'device.role'} = $self->cgi->param('filter_device_role') if ($self->cgi->param('filter_device_role'));	
	$filters{'device.hardware'} = $self->cgi->param('filter_device_hardware') if ($self->cgi->param('filter_device_hardware'));	
	$filters{'device.os'} = $self->cgi->param('filter_device_os') if ($self->cgi->param('filter_device_os'));	

	return \%filters;
}

sub deviceSearch
{
	my $self = shift;
	return $self->cgi->param('device_search') if ($self->cgi->param('device_search'));
}

sub showFilters
{
	my $self = shift;
	return $self->cgi->param('show_filters');
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
	my $type = shift || 'text/html';
	return $self->cgi->header($type);
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

sub id
{
	my ($self, $view) = @_;
	my $id = $self->cgi->param($view.'_id');	
	$id += 0;
	return $id;	
}

sub rackList
{
	my $self = shift;
	return $self->cgi->param('rack_list');
}

sub selectProperty # should get all prefill vars going via this sub
{
	my ($self, $property) = @_;
	return $self->cgi->param('select_'.$property);	
}



##############################################################################
# Select List Methods                                                        #
##############################################################################

sub selectItem
{
	my ($self, $items, $selectedId) = @_;
	$selectedId ||= 0;

	for my $i (@$items)
	{
		$$i{'selected'} = ($$i{'id'} eq $selectedId); # choose selected item
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
		if (length($$i{'building_name_short'}) > 0)
		{
			$$i{'name'} = $$i{'name'}.' in '.$$i{'room_name'}.' in '.$$i{'building_name_short'} unless $$i{'meta_default_data'};
		}
		else
		{
			$$i{'name'} = $$i{'name'}.' in '.$$i{'room_name'}.' in '.$$i{'building_name'} unless $$i{'meta_default_data'};
		}
	}
	return $items;
}

sub selectHardware
{
	my ($self, $items, $selectedId) = @_;
	$items = $self->selectItem($items, $selectedId);

	for my $i (@$items)
	{
		$$i{'name'} = $$i{'manufacturer_name'}.' '.$$i{'name'} unless $$i{'meta_default_data'} or $$i{'manufacturer_meta_default_data'};
	}
	return $items;
}