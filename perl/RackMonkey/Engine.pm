package RackMonkey::Engine;
########################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org
# Version 1.2.%BUILD%
# (C)2007 Will Green (wgreen at users.sourceforge.net)
# DBI Engine for Rackmonkey
########################################################################

use strict;
use warnings;

use 5.006_001;

use Data::Dumper; # For debug only

use RackMonkey::Conf;
use RackMonkey::Helper;

our $VERSION = '1.2.%BUILD%';
our $AUTHOR = 'Will Green (wgreen at users.sourceforge.net)';



################################################################################
# Common Methods                                                               #
################################################################################

sub new
{
	my $className = shift;
	my $dbh = shift;
	my $self = {'dbh' => $dbh};
	bless $self, $className;
}

sub getEntryBasic
{
	my ($self, $id, $table) = @_;
	die 'RMERR: Not a valid table.' unless $table =~ /^[a-z_]+$/;
	my $sth = $self->dbh->prepare_cached(qq!SELECT id, name FROM $table WHERE id = ?!);
	$sth->execute($id);
	my $entry = $sth->fetchrow_hashref('NAME_lc');
	die "RMERR: No such entry '$id' in table '$table'.\nError occured" unless defined($$entry{'id'});
	return $entry;
}

sub getListBasic
{
	my ($self, $table) = @_;
	die "RMERR: Not a valid table." unless $table =~ /^[a-z_]+$/;
	my $sth = $self->dbh->prepare_cached(qq!SELECT id, name FROM $table ORDER BY meta_default_data DESC, name!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub getListBasicSelected
{
	my ($self, $table, $selectedId) = @_;
	my $list = $self->getListBasic($table);

	for my $item (@$list)
	{
		$$item{'selected'} = ($$item{'id'} == $selectedId);
	}
	return $list;
}

sub getEntryId # This won't work for things like rooms, where the name might not be unique (rooms in different buildings can share names)
{
	my ($self, $name, $table) = @_;
	die 'RMERR: Not a valid table.\nError occured' unless $table =~ /^[a-z]+$/;
	my $sth = $self->dbh->prepare_cached(qq!SELECT id FROM $table WHERE name = ?!);
	$sth->execute($name);
	my $entry = $sth->fetchrow_hashref('NAME_lc');
	die 'RMERR: No such entry name.\nError occured' unless defined($$entry{'id'});
	return $$entry{'id'};
}

sub performAct
{
	my ($self, $type, $act, $updateUser, $record) = @_;
	die "RMERR: '$type' is not a recognised type. This error should not occur, did you manually type this URL?\nError occured" unless $type =~ /^(?:building|room|row|rack|device|hardware|os|service|role|domain|org)$/;
	die "RMERR: '$act is not a recognised act. This error should not occur, did you manually type this URL?\nError occured" unless $act =~ /^(?:update|delete)$/;
	
	# check username for update is valid
	die "RMERR: User update names must be less than ".MAXSTRING." characters.\nError occured" unless (length($updateUser) <= MAXSTRING);
	die "RMERR: You cannot use the username 'install', it's reserved for use by Rackmonkey.\nError occured" if (lc($updateUser) eq 'install');
	die "RMERR: You cannot use the username 'rackmonkey', it's reserved for use by Rackmonkey.\nError occured" if (lc($updateUser) eq 'rackmonkey');
	
	# calculate update time (always GMT)
	my ($sec, $min, $hour, $day, $month, $year) = (gmtime)[0,1,2,3,4,5];
	$year += 1900;
	$month++;
	my $updateTime = sprintf('%04d-%02d-%02d %02d:%02d:%02d', $year, $month, $day, $hour, $min, $sec);
		
	$type = $act.ucfirst($type);
	return $self->$type($updateTime, $updateUser, $record);
}



################################################################################
# Building Methods                                                             #
################################################################################

sub getBuilding
{
	my ($self, $id) = @_;
	die "RMERR: Unable to retrieve building. No building id specified.\nError occured" unless ($id);
	my $sth = $self->dbh->prepare(qq!
		SELECT building.* 
		FROM building 
		WHERE id = ?
	!);
	$sth->execute($id);	
	my $building = $sth->fetchrow_hashref('NAME_lc');
	die "RMERR: No such building id.\nError occured" unless defined($$building{'id'});
	return $building;
}

sub getBuildingCount
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT count(*) 
		FROM building 
	!);
	$sth->execute();
	return ($sth->fetchrow_array)[0];
}

sub getBuildingList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'building.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;
	$orderBy = $orderBy.', building.name' unless $orderBy eq 'building.name'; # default second ordering is name
	$orderBy = 'building.meta_default_data, '.$orderBy; # ensure meta default entries appear last
	my $sth = $self->dbh->prepare_cached(qq!
		SELECT building.* 
		FROM building 
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateBuilding
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update building. No building record specified.\nError occured" unless ($record);
	
	my ($sth, $newId);

	if ($$record{'act_id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE building SET name = ?, name_short = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateBuildingUpdate($record), $updateTime, $updateUser, $$record{'act_id'});
		die "RMERR: Update failed. This building may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO building (name, name_short, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateBuildingUpdate($record), $updateTime, $updateUser);
		$newId = $self->_getLastInsertId();
	}
	return $newId || $$record{'act_id'};
}

sub deleteBuilding
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'act_id'} : $record;
	die "RMERR: Delete failed. No building id specified.\nError occured" unless ($deleteId);
	my $sth = $self->dbh->prepare('DELETE FROM building WHERE id = ?');
	my $ret = $sth->execute($deleteId);
	die "RMERR: Delete failed. This building does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
}

sub deleteBuildingList
{
	my ($self, $updateTime, $updateUser, $buildingList) = @_;
	die "RMERR: This method is not yet supported.\nError occured";
}

sub _validateBuildingUpdate
{
	my ($self, $record) = @_;
	die "RMERR_INTERNAL: Unable to validate building. No building record specified.\nError occured" unless ($record);
	checkName($$record{'name'});
	# need to add validation for short name
	checkNotes($$record{'notes'});
	return ($$record{'name'}, $$record{'name_short'}, $$record{'notes'});
}



################################################################################
# Room Methods                                                                 #
################################################################################

sub getRoom
{
	my ($self, $id) = @_;
	die "RMERR: Unable to retrieve room. No room id specified.\nError occured" unless ($id);
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			room.*, 
			building.name		AS building_name,
			building.name_short	AS building_name_short,
			building.meta_default_data	AS building_meta_default_data			
		FROM room, building 
		WHERE
			room.building = building.id AND
			room.id = ?
	!);
	$sth->execute($id);	
	my $room = $sth->fetchrow_hashref('NAME_lc');
	die "RMERR: No such room id.\nError occured" unless defined($$room{'id'});
	return $room;
}

sub getRoomCount
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT count(*) 
		FROM room 
	!);
	$sth->execute();
	return ($sth->fetchrow_array)[0];
}

sub getRoomList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'building.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	# by default, order by building name first
	$orderBy = $orderBy.', room.name' unless $orderBy eq 'room.name'; # default second ordering is room name
	$orderBy = 'room.meta_default_data, '.$orderBy; # ensure meta (default) entries appear last
	my $sth = $self->dbh->prepare(qq!
		SELECT
			room.*,
			building.name		AS building_name,
			building.name_short	AS building_name_short,
			building.meta_default_data	AS building_meta_default_data			
		FROM room, building
		WHERE
			room.building = building.id
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub getRoomListInBuilding
{
	my $self = shift;
	my $building = shift;
	$building += 0; # force building to be numeric
	my $orderBy = shift || '';
	$orderBy = 'building.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	
	$orderBy = 'building.meta_default_data, '.$orderBy; # ensure meta (default) entries appear last
	my $sth = $self->dbh->prepare(qq!
		SELECT
			room.*,
			building.name		AS building_name,
			building.name_short	AS building_name_short,
			building.meta_default_data	AS building_meta_default_data			
		FROM room, building
		WHERE
			room.building = building.id AND
			room.building = ?
		ORDER BY $orderBy
	!);
	$sth->execute($building);
	return $sth->fetchall_arrayref({});
}

sub getRoomListBasic
{
	my $self = shift;
	my $sth = $self->dbh->prepare(q!
		SELECT 
			room.id, 
			room.name, 
			building.name AS building_name,
			building.name_short	AS building_name_short,
			building.meta_default_data	AS building_meta_default_data			
		FROM room, building 
		WHERE 
			room.building = building.id 
		ORDER BY 
			room.meta_default_data DESC, 
			room.name
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({'id' => 1, 'name' => 1, 'building_name' => 1});
}

sub getRoomListBasicSelected
{
	my ($self, $selectedId) = @_;
	$selectedId += 0;
	
	my $rooms = $self->getRoomListBasic();
	
	if ($selectedId)
	{
		for my $r (@$rooms)
		{
			$$r{'selected'} = ($$r{'id'} == $selectedId);
		}
	}
	
	return $rooms;
}

sub updateRoom
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update room. No room record specified.\nError occured" unless ($record);
		
	my ($sth, $newId);
	
	if ($$record{'act_id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE room SET name = ?, building =?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateRoomUpdate($record), $updateTime, $updateUser, $$record{'act_id'});
		die "RMERR: Update failed. This room may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$self->dbh->{AutoCommit} = 0;    # need to update room and row table together
		eval
		{
			$sth = $self->dbh->prepare(qq!INSERT INTO room (name, building, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
			$sth->execute($self->_validateRoomUpdate($record), $updateTime, $updateUser);
			$newId = $self->_getLastInsertId();
			my $hiddenRow = {'name' => '-', room => "$newId", 'room_pos' => 0, 'hidden_row' => 1, 'notes' => ''}; 
			$self->updateRow($updateTime, $updateUser, $hiddenRow);
			$self->dbh->commit();
		};
		if ($@)
		{
			my $errorMsg = $@;
			eval { $self->dbh->rollback(); };
			if ($@)
			{
				die "RMERR: Room creation failed - $errorMsg\nIn addition transaction roll back failed - $@\nError occured";
			}
			die "RMERR: Room creation failed - $errorMsg\nError occured";
		}
		$self->dbh->{AutoCommit} = 1; 
	}
	return $newId || $$record{'act_id'};
}

sub deleteRoom
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'act_id'} : $record;
	die "RMERR: Delete failed. No room id specified.\nError occured" unless ($deleteId);
	
	my ($ret, $sth);
	$self->dbh->{AutoCommit} = 0;    # need to delete room and hidden rows together
	eval
	{
		$sth = $self->dbh->prepare('DELETE FROM row WHERE hidden_row = 1 AND room = ?');
		$sth->execute($deleteId);
		$sth = $self->dbh->prepare('DELETE FROM room WHERE id = ?');
		$ret = $sth->execute($deleteId);
		$self->dbh->commit();
	};
	if ($@)
	{
		my $errorMsg = $@;
		eval { $self->dbh->rollback(); };
		if ($@)
		{
			die "RMERR: Room deletion failed - $errorMsg\nIn addition transaction roll back failed - $@\nError occured";
		}
		die "RMERR: Room deletion failed - $errorMsg\nError occured";
	}	
	$self->dbh->{AutoCommit} = 1; 
	die "RMERR: This room does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
}

sub deleteRoomList
{
	my ($self, $updateTime, $updateUser, $roomList) = @_;
	die "RMERR: This method is not yet supported.\nError occured";
}

sub _validateRoomUpdate
{
	my ($self, $record) = @_;
	die "RMERR_INTERNAL: Unable to validate building. No building record specified.\nError occured" unless ($record);
	checkName($$record{'name'});
	checkNotes($$record{'notes'});
	return ($$record{'name'}, $$record{'building_id'}, $$record{'notes'});
}




#########################
######## Row API ########
#########################

sub getRow
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			row.*,
			room.name			AS room_name,
			building.name		AS building_name,
			building.name_short	AS building_name_short,
			building.meta_default_data	AS building_meta_default_data			
		FROM row, room, building 
		WHERE
			row.room = room.id AND
			room.building = building.id AND
			row.id = ?
	!);
	$sth->execute($id);	
	my $row = $sth->fetchrow_hashref('NAME_lc');
	die "RMERR: No such row id.\nError occured" unless defined($$row{'id'});
	return $row;
}

sub getRowList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'building.name, room.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	# by default, order by building name and room name first
	$orderBy = $orderBy.', row.name' unless $orderBy eq 'row.name'; # default third ordering is row name
	$orderBy = 'row.meta_default_data, '.$orderBy; # ensure meta (default) entries appear last
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			row.*,
			room.name			AS room_name,
			building.name		AS building_name,
			building.name_short	AS building_name_short,
			building.meta_default_data	AS building_meta_default_data			
		FROM row, room, building 
		WHERE
			row.room = room.id AND
			room.building = building.id
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateRow
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update row. No row record specified.\nError occured" unless ($record);
		
	if ($$record{'act_id'})
	{	
		my $sth = $self->dbh->prepare(qq!UPDATE row SET name = ?, room = ?, room_pos = ?, hidden_row = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateRowUpdate($record), $updateTime, $updateUser, $$record{'act_id'});
		die "RMERR: Update failed. This row may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		my $sth = $self->dbh->prepare(qq!INSERT INTO row (name, room, room_pos, hidden_row, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateRowUpdate($record), $updateTime, $updateUser);
	}
}

# extra row subs that include room, building information

sub getRowListInRoom
{
	my ($self, $room) = @_;
	$room += 0; # force room to be numeric
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			row.*,
			room.name			AS room_name,
			building.name		AS building_name,
			building.name_short	AS building_name_short,
			building.meta_default_data	AS building_meta_default_data			
		FROM row, room, building 
		WHERE
			row.room = room.id AND
			room.building = building.id AND
			row.room = ?
		ORDER BY row.room_pos
	!);
	$sth->execute($room);
	return $sth->fetchall_arrayref({});
}

sub getRowListInRoomBasic
{
	my ($self, $room) = @_;
	$room += 0; # force room to be numeric
	my $sth = $self->dbh->prepare(qq!
		SELECT
			row.id,
			row.name
		FROM row
		WHERE
			row.room = ?
		ORDER BY row.name
	!);
	$sth->execute($room);
	return $sth->fetchall_arrayref({});
}

sub getRowCountInRoom
{
	my ($self, $room) = @_;
	$room += 0; # force room to be numeric
	my $sth = $self->dbh->prepare(qq!
		SELECT
			count (*)
		FROM row
		WHERE
			row.room = ?
	!);
	$sth->execute($room);
	my $countRef = $sth->fetch;
	return $$countRef[0];
}

sub _validateRowUpdate
{
	my ($self, $record) = @_;
	die "RMERR_INTERNAL: Unable to validate row. No building record specified.\nError occured" unless ($record);
	checkName($$record{'name'});
	checkNotes($$record{'notes'});
	return ($$record{'name'}, $$record{'room'}, $$record{'room_pos'}, $$record{'hidden_row'}, $$record{'notes'});
}


#########################
######## Rack API #######
#########################

sub getRack
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			rack.*,
			row.name			AS row_name,
			room.name			AS room_name,
			building.name		AS building_name, 
			building.name_short	AS building_name_short,
			building.meta_default_data	AS building_meta_default_data
		FROM rack, row, room, building 
		WHERE
			rack.row = row.id AND
			row.room = room.id AND
			room.building = building.id AND
			rack.id = ?
	!);
	$sth->execute($id);	
	my $rack = $sth->fetchrow_hashref('NAME_lc');
	die "RMERR: No such rack id.\nError occured" unless defined($$rack{'id'});
	return $rack;
}

sub getRackList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'building.name, room.name, row.name, rack.row_pos' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	# by default, order by building name and room name first
	$orderBy = $orderBy.', rack.row_pos, rack.name' unless ($orderBy eq 'rack.row_pos, rack.name' or $orderBy eq 'rack.name'); # default third ordering is rack name
	$orderBy = 'rack.meta_default_data, '.$orderBy; # ensure meta (default) entries appear last
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			rack.*,
			row.name			AS row_name,
			room.name			AS room_name,
			building.name		AS building_name,
			building.name_short	AS building_name_short,
			building.meta_default_data	AS building_meta_default_data
		FROM rack, row, room, building 
		WHERE
			rack.row = row.id AND
			row.room = room.id AND
			room.building = building.id
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub getRackTableBasic
{
	my $self = shift;
	my $whereId = shift;
	$whereId += 0; # force numerical
	my $where = $whereId ? "WHERE row.id = $whereId" : '';
	my $sth = $self->dbh->prepare(qq!SELECT id, name, row_name, room_name FROM location $where ORDER BY name!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}


sub getRackPhysical # This method is all rather inelegant
{
	my ($self, $rackid) = @_;
	my $devices = $self->getDeviceListInRack($rackid);

	my $sth = $self->dbh->prepare(qq!
		SELECT 
			rack.*
		FROM rack
		WHERE rack.id = ?
	!);
	$sth->execute($rackid);
	my $rack = $sth->fetchrow_hashref('NAME_lc');

	my @rackLayout;
	my $debugOut;
	
	# adjust device positions so they start from the *highest* rack position
	for my $dev (@$devices)
	{	
		if ($$dev{'hardware_size'} > 1)
		{
			$$dev{'rack_pos'} += $$dev{'hardware_size'} - 1;
		}
	}

	my $position = $$rack{'size'};
	while ($position > 0)
	{
		for my $dev (@$devices)
		{
			if ($$dev{'rack_pos'} == $position)
			{
				$rackLayout[$position] = $dev;
				my $size = $$dev{'hardware_size'} || 0;
				while ($size > 1)
				{
					$position--;
					$size--;
					$rackLayout[$position] = {'rack_pos' => $position, 'id' => 0, 'name' => '', 'hardware_size' => '0'};
				}
			}
		}
		unless (defined($rackLayout[$position]))
		{
			$rackLayout[$position] = {'rack_pos' => $position, 'id' => 0, 'name' => '', 'hardware_size' => '1'};	
		}
		$position--;
	}
	shift @rackLayout; # remove superfluous last entry

	# Format rack positions to be fixed length for racks up to 1000U
	my $posFormat = "%d";
	if (($$rack{'size'} >= 10) && ($$rack{'size'} < 100))
	{
		$posFormat = "%02d";
	}
	elsif (($$rack{'size'} >= 100) && ($$rack{'size'} < 1000))
	{
		$posFormat = "%03d";
	}
	for my $r (@rackLayout)
	{
		$$r{'rack_pos'} = sprintf($posFormat, $$r{'rack_pos'});
	}	
	
	@rackLayout = reverse @rackLayout; # low numbers at bottom of rack - should be configurable
	
	return \@rackLayout;
}

sub updateRack
{
	my $self = shift;
	my $id = shift;
	eval { $self->getEntryBasic($id, 'rack'); };
	die 'updateRack: That id is not a rack. Another user may have removed this rack entry.' if ($@);
	my $sth = $self->dbh->prepare(qq!UPDATE rack SET name = ?, room = ?, size = ?, notes = ? WHERE id = ?!);
	$sth->execute($self->validateRackInput(@_,$id),$id);
}

sub createRack
{
	my $self = shift;
	my $sth = $self->dbh->prepare(q!INSERT INTO rack (name, room, size, notes) VALUES(?, ?, ?, ?)!);
	$sth->execute($self->validateRackInput(@_));
}

sub deleteRack
{
	my ($self, $record) = @_;
	my $sth = $self->dbh->prepare(qq!DELETE FROM rack WHERE id = ?!);
	$sth->execute($$record{'act_id'});	
}

# extra rack subs that include row, room, building information

sub getRackListBasic
{
	my $self = shift;
	my $sth = $self->dbh->prepare(q!
		SELECT
			rack.id,
			rack.name,
			rack.meta_default_data,
			row.id			AS row_id,
			row.name		AS row_name,
			room.id			AS room_id, 
			room.name		AS room_name, 
			building.name	AS building_name,
			building.name_short	AS building_name_short,
			building.meta_default_data AS building_meta_default_data
		FROM rack, row, room, building 
		WHERE
			rack.row = row.id AND
			row.room = room.id AND
			room.building = building.id 
		ORDER BY 
			rack.meta_default_data DESC, 
			building.name,
			room.name,
			row.room_pos,
			rack.row_pos
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub getRackListBasicSelected
{
	my ($self, $selectedId) = @_;
	$selectedId += 0;
	
	my $racks = $self->getRackListBasic();
	
	if ($selectedId)
	{
		for my $r (@$racks)
		{
			$$r{'selected'} = ($$r{'id'} == $selectedId);
		}
	}
	
	return $racks;
}



##############################
######## Hardware API ########
##############################

sub getHardware
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT
			hardware.*,
			org.name 				AS manufacturer_name
		FROM hardware, org
		WHERE 
			hardware.manufacturer = org.id AND
			hardware.id = ?
	!);	
		
	$sth->execute($id);	
	my $hardware = $sth->fetchrow_hashref();
	die "RMERR: No such hardware id. This item of hardware may have been deleted.\nError at" unless defined($$hardware{'id'});
	return $hardware;
}

sub getHardwareList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'hardware.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	
	$orderBy = 'hardware.meta_default_data, '.$orderBy;
	my $sth = $self->dbh->prepare(qq!
		SELECT
			hardware.*,
			org.name 				AS manufacturer_name
		FROM hardware, org
		WHERE hardware.manufacturer = org.id
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateHardware # should check if update/insert was successful
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	
	my $sth;
	
	if ($$record{'act_id'}) # if id is supplied peform an update
	{	
		$sth = $self->dbh->prepare(qq!UPDATE hardware SET name = ?, manufacturer =?, size = ?, image = ?, support_url = ?, spec_url = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		$sth->execute($self->validateHardwareUpdate($record), $updateTime, $updateUser, $$record{'act_id'});
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO hardware (name, manufacturer, size, image, support_url, spec_url, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)!);
		$sth->execute($self->validateHardwareUpdate($record), $updateTime, $updateUser);
	}
}

sub deleteHardware # should check we successfully deleted if possible
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $sth = $self->dbh->prepare('DELETE FROM hardware WHERE id = ?');
	$sth->execute($$record{'act_id'});	
}

sub validateHardwareUpdate
{
	my ($self, $record) = @_;
	
	$$record{'support_url'} = httpFixer($$record{'support_url'});
	$$record{'spec_url'} = httpFixer($$record{'spec_url'});

	die "RMERR: You must specify a name for the hardware.\nError occured" unless (length($$record{'name'}) > 1);
	die "RMERR: Names must be less than ".MAXSTRING." characters.\nError occured" unless (length($$record{'name'}) <= MAXSTRING);
	# no validation for $$record{'manufacturer_id'} - foreign key constraints will catch
	die "RMERR: Size must be between 1 and ".MAXRACKSIZE." units." unless (($$record{'size'} > 0) && ($$record{'size'} <= MAXRACKSIZE));
	die "RMERR: Image filenames must be between 0 and ".MAXSTRING." characters." unless ((length($$record{'image'}) >= 0) && (length($$record{'image'}) <= MAXSTRING));
	die "RMERR: Support URLs must be between 0 and ".MAXSTRING." characters." unless ((length($$record{'support_url'}) >= 0) && (length($$record{'support_url'}) <= MAXSTRING));
	die "RMERR: Specification URLs must be between 0 and ".MAXSTRING." characters." unless ((length($$record{'spec_url'}) >= 0) && (length($$record{'spec_url'}) <= MAXSTRING));
	die "RMERR: Notes cannot exceed ".MAXNOTE." characters." unless (length($$record{'notes'}) <= MAXNOTE);
	
	return ($$record{'name'}, $$record{'manufacturer_id'}, $$record{'size'}, $$record{'image'}, $$record{'support_url'}, $$record{'spec_url'}, $$record{'notes'});
}


######################################
######## Operating System API ########
######################################

sub getOs
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			os.*,
			org.name 			AS manufacturer_name
		FROM os, org 
		WHERE 
			os.manufacturer = org.id AND
			os.id = ?
	!);
	
	$sth->execute($id);	
	my $os = $sth->fetchrow_hashref('NAME_lc');
	die "RMERR: No such operating system id. This operating system may have been deleted.\nError occured" unless defined($$os{'id'});
	return $os;
}

sub getOsList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'os.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;
	$orderBy = 'os.meta_default_data, '.$orderBy;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			os.*,
			org.name 			AS manufacturer_name 
		FROM os, org 
		WHERE os.manufacturer = org.id
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateOs # should check if update/insert was successful
{
	my ($self, $updateTime, $updateUser, $record) = @_;

	my $sth;
	
	if ($$record{'act_id'}) # if id is supplied peform an update
	{	
		$sth = $self->dbh->prepare(qq!UPDATE os SET name = ?, manufacturer = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		$sth->execute($self->validateOs($record), $updateTime, $updateUser, $$record{'act_id'});
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO os (name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
		$sth->execute($self->validateOs($record), $updateTime, $updateUser);
	}
}

sub deleteOs # should check we successfully deleted if possible
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $sth = $self->dbh->prepare(qq!DELETE FROM os WHERE id = ?!);
	$sth->execute($$record{'act_id'});	
}

sub validateOs
{
	my ($self, $record) = @_;
	die "RMERR: You must specify a name for the operating system.\nError occured" unless (length($$record{'name'}) > 1);
	die "RMERR: Names must be less than ".MAXSTRING." characters.\nError occured" unless (length($$record{'name'}) <= MAXSTRING);
	# no validation for $$record{'manufacturer_id'} - foreign key constraints will catch
	die "RMERR: Notes cannot exceed '.MAXNOTE.' characters.\nError occured" unless (length($$record{'notes'}) <= MAXNOTE);
	return ($$record{'name'}, $$record{'manufacturer_id'}, $$record{'notes'});
}


##################################
######## Organisation API ########
##################################

sub getOrg
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT org.*
		FROM org 
		WHERE id = ?
	!);
	$sth->execute($id);	
	my $org = $sth->fetchrow_hashref('NAME_lc');
	die 'RMERR: No such organisation id.' unless defined($$org{'id'});
	return $org;
}

sub getOrgList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'org.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;
	$orderBy = 'org.meta_default_data, '.$orderBy;
	
	my $sth = $self->dbh->prepare(qq!
		SELECT org.*
		FROM org
 		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateOrg # should check if update/insert was successful
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	
	my $sth;
	
	if ($$record{'act_id'}) # if id is supplied peform an update
	{	
		$sth = $self->dbh->prepare(qq!UPDATE org SET name = ?, account_no = ?, customer = ?, software = ?, hardware = ?, descript = ?, home_page = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		$sth->execute($self->validateOrgUpdate($record), $updateTime, $updateUser, $$record{'act_id'});
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO org (name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)!);
		$sth->execute($self->validateOrgUpdate($record), $updateTime, $updateUser);
	}
}

sub deleteOrg
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $sth = $self->dbh->prepare('DELETE FROM org WHERE id = ?');
	$sth->execute($$record{'act_id'});	
}

sub validateOrgUpdate
{
	my ($self, $record) = @_;

	$$record{'home_page'} = httpFixer($$record{'home_page'});

	die "RMERR: You must specify a name for the organisation.\nError occured" unless (length($$record{'name'}) > 1);
	die "RMERR: Names must be less than ".MAXSTRING." characters.\nError occured" unless (length($$record{'name'}) <= MAXSTRING);
	die "RMERR: Account numbers must be less than ".MAXSTRING." characters.\nError occured" unless (length($$record{'account_no'}) <= MAXSTRING);
	die "RMERR: Descriptions cannot exceed ".MAXNOTE." characters.\nError occured" unless (length($$record{'descript'}) <= MAXNOTE);
	die "RMERR: Home page URLs cannot exceed ".MAXSTRING." characters.\nError occured" unless (length($$record{'home_page'}) <= MAXSTRING);
	die "RMERR: Notes cannot exceed ".MAXNOTE." characters.\nError occured" unless (length($$record{'notes'}) <= MAXNOTE);
	
	# normalise input for boolean values
	$$record{'customer'} = $$record{'customer'} ? 1 : 0;
	$$record{'software'} = $$record{'software'} ? 1 : 0;
	$$record{'hardware'} = $$record{'hardware'} ? 1 : 0;
	
	return ($$record{'name'}, $$record{'account_no'}, $$record{'customer'}, $$record{'software'}, $$record{'hardware'}, $$record{'descript'}, $$record{'home_page'}, $$record{'notes'});
}


############################
######## Domain API ########
############################

sub getDomain
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT domain.*
		FROM domain
		WHERE id = ?
	!);
	$sth->execute($id);	
	my $domain = $sth->fetchrow_hashref('NAME_lc');
	die "RMERR: No such domain id.\nError occured" unless defined($$domain{'id'});
	return $domain;
}

sub getDomainList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'domain.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;
	$orderBy = 'domain.meta_default_data, '.$orderBy;
	
	my $sth = $self->dbh->prepare(qq!
		SELECT domain.*
		FROM domain 
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateDomain # should check if update/insert was successful
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	
	my $sth;
	
	if ($$record{'act_id'}) # if id is supplied peform an update
	{	
		$sth = $self->dbh->prepare(qq!UPDATE domain SET name = ?, descript = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		$sth->execute($self->validateDomainUpdate($record), $updateTime, $updateUser, $$record{'act_id'});
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO domain (name, descript, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
		$sth->execute($self->validateDomainUpdate($record), $updateTime, $updateUser);
	}
}

sub deleteDomain
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $sth = $self->dbh->prepare(qq!DELETE FROM domain WHERE id = ?!);
	$sth->execute($$record{'act_id'});	
}

sub validateDomainUpdate # Should we remove or warn on domains beginning with . ?
{
	my ($self, $record) = @_;
	die "RMERR: You must specify a name for the domain.\nError occured" unless (length($$record{'name'}) > 1);
	die "RMERR: Names must be less than ".MAXSTRING." characters.\nError occured" unless (length($$record{'name'}) <= MAXSTRING);
	die "RMERR: Descriptions cannot exceed ".MAXSTRING." characters.\nError occured" unless (length($$record{'descript'}) <= MAXSTRING);
	die "RMERR: Notes cannot exceed ".MAXNOTE." characters.\nError occured" unless (length($$record{'notes'}) <= MAXNOTE);
	return ($$record{'name'}, $$record{'descript'}, $$record{'notes'});
}


############################
######## Device API ########
############################

sub getDevice
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			device.*, 
			rack.name 					AS rack_name,
			rack.id						AS rack_id,
			row.name					AS row_name,
			row.id						AS row_id,
			room.name					AS room_name,
			room.id						AS room_id,
			building.name				AS building_name,
			building.name_short			AS building_name_short,			
			building.id					AS building_id,	
			building.meta_default_data	AS building_meta_default_data,
			hardware.name 				AS hardware_name,
			hardware_manufacturer.name	AS hardware_manufacturer_name,
			role.name 					AS role_name, 
			os.name 					AS os_name, 
			customer.name 				AS customer_name,
			service.name 				AS service_name,
			domain.name					AS domain_name,
			domain.meta_default_data	AS domain_meta_default_data
		FROM device, rack, row, room, building, hardware, org hardware_manufacturer, role, os, org customer, service, domain 
		WHERE 
			device.rack = rack.id AND 
			rack.row = row.id AND
			row.room = room.id AND
			room.building = building.id AND			
			device.hardware = hardware.id AND 
			hardware.manufacturer = hardware_manufacturer.id AND
			device.role = role.id AND
			device.os = os.id AND
			device.customer = customer.id AND
			device.domain = domain.id AND
			device.service = service.id AND
			device.id = ?
	!);
	$sth->execute($id);	
	my $device = $sth->fetchrow_hashref('NAME_lc');
	die 'RMERR: No such device id.' unless defined($$device{'id'});
	return $device;
}

sub getDeviceList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'device.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	
	$orderBy = 'device.meta_default_data, '.$orderBy;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			device.*, 
			rack.name 					AS rack_name,
			rack.id						AS rack_id,
			row.name					AS row_name,
			row.id						AS row_id,
			room.name					AS room_name,
			room.id						AS room_id,
			building.name				AS building_name,
			building.name_short			AS building_name_short,			
			building.id					AS building_id,	
			building.meta_default_data	AS building_meta_default_data,
			hardware.name 				AS hardware_name,
			hardware_manufacturer.name	AS hardware_manufacturer_name,
			role.name 					AS role_name, 
			os.name 					AS os_name, 
			customer.name 				AS customer_name,
			service.name 				AS service_name,
			domain.name					AS domain_name,
			domain.meta_default_data	AS domain_meta_default_data
		FROM device, rack, row, room, building, hardware, org hardware_manufacturer, role, os, org customer, service, domain 
		WHERE 
			device.rack = rack.id AND 
			rack.row = row.id AND
			row.room = room.id AND
			room.building = building.id AND			
			device.hardware = hardware.id AND 
			hardware.manufacturer = hardware_manufacturer.id AND
			device.role = role.id AND
			device.os = os.id AND
			device.customer = customer.id AND
			device.domain = domain.id AND
			device.service = service.id
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub getDeviceListInRack
{
	my ($self, $rack) = @_;
	$rack += 0; # force rack to be numerical
	
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			device.*,
			rack.name 					AS rack_name,
			rack.id						AS rack_id,
			building.meta_default_data	AS building_meta_default_data,
			hardware.name 				AS hardware_name,
			hardware_manufacturer.name	AS hardware_manufacturer_name,
			hardware.size				AS hardware_size,
			domain.name					AS domain_name,
			domain.meta_default_data	AS domain_meta_default_data
		FROM
			device, rack, row, room, building, hardware, org hardware_manufacturer, domain
		WHERE
			device.rack = rack.id AND 
			rack.row = row.id AND
			row.room = room.id AND
			room.building = building.id AND				
			device.hardware = hardware.id AND
			hardware.manufacturer = hardware_manufacturer.id AND
			device.domain = domain.id AND
			rack.id = ?
		ORDER BY rack.row_pos
	!);
	
	$sth->execute($rack);
	#die Dumper $sth->fetchall_arrayref({});
	return $sth->fetchall_arrayref({});		
}

sub updateDevice
{
	my $self = shift;
	my $id = shift;
	eval { $self->getEntryBasic($id, 'device'); };
	die 'RMERR: That id is not a valid device. Another user may have removed this device entry.' if ($@);
	my $sth = $self->dbh->prepare('UPDATE device SET name = ?, rack =?, rack_pos = ?, hardware = ?, serial = ?, asset = ?, purchased = ?, os = ?, customer = ?, service = ?, role = ?, monitor_url =?, notes = ? WHERE id = ?');
	$sth->execute($self->validateDeviceInput(@_), $id);
}

sub createDevice
{
	my $self = shift;
	my $sth = $self->dbh->prepare('INSERT INTO device (name, rack, rack_pos, hardware, serial, asset, purchased, os, customer, service, role, monitor_url, notes) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
	$sth->execute($self->validateDeviceInput(@_));
}

sub deleteDevice
{
	my ($self, $record) = @_;
	my $sth = $self->dbh->prepare('DELETE FROM device WHERE id = ?');
	$sth->execute($$record{'act_id'});	
}

sub validateDeviceInput
{
	my ($self, $name, $rack, $rackPos, $hardware, $serial, $asset, $purchased, $os, $customer, $service, $role, $monitor, $notes) = @_;
	$monitor = httpFixer($monitor);
	die 'RMERR: Names must be between 1 and '.MAXSTRING.' characters.' unless ((length($name) > 1) && (length($name) <= MAXSTRING));
	eval { $self->getEntryBasic($rack, 'rack'); };
	die 'RMERR: That id is not a valid rack. Please check your rack list.' if ($@);
	die 'RMERR: Rack position must be between 0 and '.MAXRACKSIZE.' units.' unless (($rackPos > 0) && ($rackPos <= MAXRACKSIZE)); # should actually check size of rack here
	eval { $self->getEntryBasic($hardware, 'hardware'); };
	die 'RMERR: That id is not a valid piece of hardware. Please check your hardware list.' if ($@);
	die 'RMERR: Serial number must be between 0 and '.MAXSTRING.' characters.' unless ((length($serial) >= 0) && (length($serial) < MAXSTRING));
	die 'RMERR: Asset number must be between 0 and '.MAXSTRING.' characters.' unless ((length($asset) >= 0) && (length($asset) < MAXSTRING));
	eval { $self->getEntryBasic($os, 'os'); };
	die 'RMERR: That id is not a valid operating system. Please check your os list.' if ($@);
	eval { $self->getEntryBasic($customer, 'org'); };
	die 'RMERR: That id is not a valid customer. Please check your organisation list.' if ($@); # should also check it's actually a customer
	eval { $self->getEntryBasic($service, 'service'); };
	die 'RMERR: That id is not a valid service level. Please check your service level list list.' if ($@);
	eval { $self->getEntryBasic($role, 'role'); };
	die 'RMERR: That id is not a valid role. Please check your role list.' if ($@);	
	die 'RMERR: Monitoring URLs must be between 0 and '.MAXSTRING.' characters.' unless ((length($monitor) >= 0) && (length($monitor) <= MAXSTRING));
	die 'RMERR: Notes cannot exceed '.MAXNOTE.' characters.' unless (length($notes) <= MAXNOTE);
	return ($name, $rack, $rackPos, $hardware, $serial, $asset, $purchased, $os, $customer, $service, $role, $monitor, $notes);
}


##########################
######## Role API ########
##########################

sub getRole
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT role.*
		FROM role 
		WHERE id = ?
	!);
	$sth->execute($id);	
	my $role = $sth->fetchrow_hashref('NAME_lc');
	die "RMERR: No such role id.\nError occured" unless defined($$role{'id'});
	return $role;
}

sub getRoleList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'role.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	
	$orderBy = 'role.meta_default_data, '.$orderBy;
	my $sth = $self->dbh->prepare(qq!
		SELECT role.* 
		FROM role 
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateRole # should check if update/insert was successful
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	
	my $sth;
	
	if ($$record{'act_id'}) # if id is supplied peform an update
	{	
		$sth = $self->dbh->prepare(qq!UPDATE role SET name = ?, descript = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		$sth->execute($self->validateDomainUpdate($record), $updateTime, $updateUser, $$record{'act_id'});
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO role (name, descript, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
		$sth->execute($self->validateDomainUpdate($record), $updateTime, $updateUser);
	}
}

sub deleteRole
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $sth = $self->dbh->prepare('DELETE FROM role WHERE id = ?');
	$sth->execute($$record{'act_id'});	
}

sub validateRoleUpdate
{
	my ($self, $record) = @_;
	die "RMERR: You must specify a name for the role.\nError occured" unless (length($$record{'name'}) > 1);
	die "RMERR: Names must be less than ".MAXSTRING." characters.\nError occured" unless (length($$record{'name'}) <= MAXSTRING);
	die "RMERR: Descriptions cannot exceed ".MAXSTRING." characters.\nError occured" unless (length($$record{'desc'}) <= MAXSTRING);
	die "RMERR: Notes cannot exceed ".MAXNOTE." characters.\nError occured" unless (length($$record{'notes'}) <= MAXNOTE);
	return ($$record{'name'}, $$record{'desc'}, $$record{'notes'});
}


###################################
######## Service Level API ########
###################################

sub getService
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT service.* 
		FROM service 
		WHERE id = ?
	!);
	$sth->execute($id);	
	my $service = $sth->fetchrow_hashref('NAME_lc');
	die "RMERR: No such service id.\nError occured" unless defined($$service{'id'});
	return $service;
}

sub getServiceList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'service.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	
	$orderBy = 'service.meta_default_data, '.$orderBy;
	my $sth = $self->dbh->prepare(qq!
		SELECT service.* 
		FROM service 
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateService # should check if update/insert was successful
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	
	my $sth;
	
	if ($$record{'act_id'}) # if id is supplied peform an update
	{	
		$sth = $self->dbh->prepare(qq!UPDATE service SET name = ?, descript = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		$sth->execute($self->validateServiceUpdate($record), $updateTime, $updateUser, $$record{'act_id'});
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO service (name, descript, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
		$sth->execute($self->validateServiceUpdate($record), $updateTime, $updateUser);
	}
}

sub deleteService
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $sth = $self->dbh->prepare('DELETE FROM service WHERE id = ?');
	$sth->execute($$record{'act_id'});	
}

sub validateServiceUpdate
{
	my ($self, $record) = @_;
	die "RMERR: You must specify a name for the service level.\nError occured" unless (length($$record{'name'}) > 1);
	die "RMERR: Names must be less than ".MAXSTRING." characters.\nError occured" unless (length($$record{'name'}) <= MAXSTRING);
	die "RMERR: Descriptions cannot exceed ".MAXSTRING." characters.\nError occured" unless (length($$record{'desc'}) <= MAXSTRING);
	die "RMERR: Notes cannot exceed ".MAXNOTE." characters.\nError occured" unless (length($$record{'notes'}) <= MAXNOTE);
	return ($$record{'name'}, $$record{'descript'}, $$record{'notes'});
}


######## Private methods - users of this class should not use these methods ########
sub _getLastInsertId # works with Postgres and SQLite, but will need altering for other DB, need to check how it deals with multiple requests from different processes
{
	my $self = shift;
	return $self->dbh->last_insert_id(undef, undef, undef, undef);
}

sub dbh
{
	my $self = shift;
	return $self->{'dbh'};
}

1;


=head1 NAME

RackMonkey::Engine - A DBI-based backend for Rackmonkey

=head1 SYNOPSIS

 use RackMonkey::Engine;

 my $dbh = DBI->connect('dbi:SQLite:dbname=/data/rack/rack.db', '', '');
 my $engine = new RackMonkey::Engine($dbh);
 my $org = $engine->getOrg(1);
 print 'The org with id 1 has the name: '.$$org{'name'};

=head1 DESCRIPTION

RackMonkey::Engine sits between the RackMonkey application and the DBI. RackMonkey::Engine abstracts the database implementation to provide a simple API for
querying and manipulating RackMonkey objects such as buildings, racks, devices, and organisations. At present the Engine works correctly with SQLite v3 and
Postgres v8. 

By overriding methods in the Engine, other sources of information may be updated or incorporated into RackMonkey. For example, customers might
be stored in a separate database, or you may wish to update a ticketing system when a device is moved to another rack. For more
information on getting RackMonkey working with other applications, see the Developer Guide which came with RackMonkey.

The rest of this document covers the RackMonkey::Engine methods, organised by the 'type' of thing they operate on:

 Common (applicable to all)
 Building
 Room
 ....

=head1 COMMON METHODS

The following methods are generic and don't apply to a particular type of RackMonkey entry.

 new ($dbh)
 getEntryBasic($id, $table)
 getListBasic($table)
 getListBasicSelected($table, $selectedId)
 getEntryId($name, $table)
 performAct() 


=head2 new($dbh)

Create a new RackMonkey::Engine object and connect it to the database handle identified by $dbh. For example:

	my $dbh = DBI->connect(DBDCONNECT, DBUSER, DBPASS);
	my $backend = new RackMonkey::Engine($dbh);

At present RackMonkey works with SQLite v3 and Postgres v8 databases. Using database handles from other databases
will produce undefined results.


=head1 BUILDING METHODS

 getBuilding($id)
 getBuildingCount()
 getBuildingList([$orderBy])
 updateBuilding($updateTime, $updateUser, $record)
 deleteBuilding($updateTime, $updateUser, $record)
 deleteBuildingList($updateTime, $updateUser, $buildingList)

=head2 getBuilding($id)

Gets a hash reference to one building specified by $id. If there is no such building the library dies.

=head2 getBuildingCount

Returns the number of buildings stored in RackMonkey.

=head2 getBuildingList([$orderBy])

Gets a list of all buildings, ordered by building property $orderBy. If $orderBy is not specified, buildings are ordered by their name
(but with default data, such as 'unknown', last in the list). If no buildings exist the returned list will be empty. Returns a reference to an array of hash
references. One hash reference per building.

=head2 updateBuilding($updateTime, $updateUser, $record)

Updates or creates a building entry based on the hash ref $record. If $$record{'id'} exists, an update will be performed,
otherwise a new building will be created. $updateTime and $updateUser set the update time and user associated with this
update. Both are strings, and may be empty. If the engine tries to update a record, but no record is updated, the Engine dies.

=head2 deleteBuilding($self, $updateTime, $updateUser, $record)

Deletes the building whose id identified by $record. deleteBuilding checks whether the record is a hash ref, and if 
so uses $$record{'act_id'} as the id, otherwise $record is taken to be the id. Support for hash refs allows deleteBuilding
to be called with the same data as an update. If no such building exists or the delete fails the library dies. $updateTime and $updateUser set
the update time and user associated with this delete; at present they are disguarded.

=head2 deleteBuildingList($updateTime, $updateUser, $buildingList)

Deletes all the buildings, specified by id in the array ref $buildingList. For example, to delete buildings with the id: 4, 6, 88:
$buildingList = [4, 6, 88]; The delete is performed as a single transaction, so either all the deletes succeed, or the Engine dies.


=head1 ROOM METHODS

 getRoom($id)
 getRoomCount()
 getRoomList([$orderBy])
 getRoomListInBuilding($building [, $orderBy]) 
 getRoomListBasic()
 getRoomListBasicSelected($selectedId)
 updateRoom($updateTime, $updateUser, $record)
 deleteRoom($updateTime, $updateUser, $record)
 deleteRoomList($updateTime, $updateUser, $roomList)

=head2 getRoom($id)

Gets a hash reference to one room specified by $id. If there is no such room the library dies.

=head2 getRoomCount()

Returns the number of rooms stored in RackMonkey.

=head2 getRoomList([$orderBy])

Gets a list of all rooms, ordered by room property $orderBy. If $orderBy is not specified, rooms are ordered by their building, then their name
(but with default data, such as 'unknown', last in the list). If no rooms exist the returned list will be empty. Returns a reference to an array of hash
references. One hash reference per room.

=head2 getRoomListInBuilding($building [, $orderBy])

As for getRoomList, but limits rooms returned to those in the building identified by the id $building. If no rooms exist in that building the returned list will be empty.


=head2 getRoomListBasic()

Because rooms reside in buildings, the common getListBasic() is often not what you want. getRoomListBasic works just like getListBasic(),
but returns the building name too. If no rooms exist the returned list will be empty.


=head2 getRoomListBasicSelected($selectedId)

As getRoomListBasic(), but also returns 'selected' for the room identified by the id $selectedId. This method is useful for generating lists
for dropdowns with a value selected. If no room matches $selectedId, no error is raised and no room is selected. If no rooms exist the returned list will be empty.

=head2 updateRoom($updateTime, $updateUser, $record)

Updates or creates a room entry based on the hash ref $record. If $$record{'id'} exists, an update will be performed,
otherwise a new room will be created. $updateTime and $updateUser set the update time and user associated with this
update. Both are strings, and may be empty. If the engine tries to update a record, but no record is updated, the Engine dies.

=head2 deleteRoom($updateTime, $updateUser, $record)

Deletes the room whose id identified by $record. deleteRoom checks whether the record is a hash ref, and if 
so uses $$record{'act_id'} as the id, otherwise $record is taken to be the id. Support for hash refs allows deleteRoom
to be called with the same data as an update. If no such room exists or the delete fails the library dies. $updateTime and $updateUser set
the update time and user associated with this delete; at present they are disguarded.

=head2 deleteRoomList($updateTime, $updateUser, $roomList)

Deletes all the rooms, specified by id in the array ref $roomList. For example, to delete rooms with the id: 4, 6, 88:
$roomList = [4, 6, 88]; The delete is performed as a single transaction, so either all the deletes succeed, or the Engine dies. 
 
 
=head1 BUGS

You can view and report bugs at http://www.rackmonkey.org

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

=head1 AUTHOR

Will Green - http://flux.org.uk

=head1 SEE ALSO

http://www.rackmonkey.org

=cut
