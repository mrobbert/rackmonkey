package RackMonkey::Engine;
##############################################################################
# RackMonkey - Know Your Racks - http://www.rackmonkey.org                   #
# Version 1.2.%BUILD%                                                        #
# (C)2007 Will Green (wgreen at users.sourceforge.net)                       #
# DBI Engine for Rackmonkey                                                  #
##############################################################################

use strict;
use warnings;

use 5.006_001;

use Data::Dumper; # for debug only - comment out from release versions

use RackMonkey::Conf;
use RackMonkey::Helper;

our $VERSION = '1.2.%BUILD%';
our $AUTHOR = 'Will Green (wgreen at users.sourceforge.net)';


##############################################################################
# Common Methods                                                             #
##############################################################################

sub new
{
	my ($className, $dbh) = @_;
	my $self = {'dbh' => $dbh};
	bless $self, $className;
}

sub dbh # should this be a private method?
{
	my $self = shift;
	return $self->{'dbh'};
}

sub entryBasic
{
	my ($self, $id, $table) = @_;
	die 'RMERR: Not a valid table.' unless $table =~ /^[a-z_]+$/;
	my $sth = $self->dbh->prepare_cached(qq!
		SELECT id, name 
		FROM $table 
		WHERE id = ?
	!);
	$sth->execute($id);
	my $entry = $sth->fetchrow_hashref('NAME_lc');
	die "RMERR: No such entry '$id' in table '$table'.\nError occured" unless defined($$entry{'id'});
	return $entry;
}

sub listBasic
{
	my ($self, $table) = @_;
	die "RMERR: Not a valid table." unless $table =~ /^[a-z_]+$/;
	my $sth = $self->dbh->prepare_cached(qq!
		SELECT 
			id, 
			name,
			meta_default_data 
		FROM $table 
		WHERE meta_default_data = 0
		ORDER BY 
			name
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub listBasicMeta
{
	my ($self, $table) = @_;
	die "RMERR: Not a valid table." unless $table =~ /^[a-z_]+$/;
	my $sth = $self->dbh->prepare_cached(qq!
		SELECT 
			id, 
			name,
			meta_default_data 
		FROM $table 
		ORDER BY 
			meta_default_data DESC,
			name
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub performAct
{
	my ($self, $type, $act, $updateUser, $record) = @_;
	die "RMERR: '$type' is not a recognised type. This error should not occur, did you manually type this URL?\nError occured" unless $type =~ /^(?:building|room|row|rack|device|hardware|os|service|role|domain|org|app|report)$/;
	my $actStr = $act;
	my $typeStr = $type;
	$act = 'update' if ($act eq 'insert');
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
	my $lastId = $self->$type($updateTime, $updateUser, $record);
	
	# log change (currently only provides basic logging)
	my $sth = $self->dbh->prepare(qq!INSERT INTO logging (table_changed, id_changed, name_changed, change_type, descript, update_time, update_user) VALUES(?, ?, ?, ?, ?, ?, ?)!);
	$sth->execute($typeStr, $lastId, $$record{'name'}, $actStr, '',  $updateTime, $updateUser);
	
	return $lastId;
}

# _lastInsertId is a private method
# works with Postgres and SQLite, but will need altering for other DB,
# need to check how it deals with multiple requests from different processes
sub _lastInsertId 
{
    my ($self, $table) = @_;
    return $self->dbh->last_insert_id(undef, undef, $table, undef);
}


##############################################################################
# Building Methods                                                           #
##############################################################################

sub building
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

sub buildingCount
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT count(*) 
		FROM building 
		WHERE meta_default_data = 0
	!);
	$sth->execute();
	return ($sth->fetchrow_array)[0];
}

sub buildingList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'building.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;
	$orderBy = $orderBy.', building.name' unless $orderBy eq 'building.name';# default second ordering is name
	my $sth = $self->dbh->prepare_cached(qq!
		SELECT building.* 
		FROM building
		WHERE meta_default_data = 0
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

	if ($$record{'id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE building SET name = ?, name_short = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateBuildingUpdate($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This building may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO building (name, name_short, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateBuildingUpdate($record), $updateTime, $updateUser);
		$newId = $self->_lastInsertId('building');
	}
	return $newId || $$record{'id'};
}

sub deleteBuilding
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No building id specified.\nError occured" unless ($deleteId);
	my $sth = $self->dbh->prepare(qq!DELETE FROM building WHERE id = ?!);
	my $ret = $sth->execute($deleteId);
	die "RMERR: Delete failed. This building does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
	return $deleteId;
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


##############################################################################
# Room Methods                                                               #  
##############################################################################

sub room
{
	my ($self, $id) = @_;
	die "RMERR: Unable to retrieve room. No room id specified.\nError occured" unless ($id);
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			room.*, 
			building.name		AS building_name,
			building.name_short	AS building_name_short
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

sub roomCount
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT count(*) 
		FROM room
		WHERE meta_default_data = 0
	!);
	$sth->execute();
	return ($sth->fetchrow_array)[0];
}

sub roomList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'building.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	# by default, order by building name first
	$orderBy = $orderBy.', room.name' unless $orderBy eq 'room.name'; # default second ordering is room name
	my $sth = $self->dbh->prepare(qq!
		SELECT
			room.*,
			building.name		AS building_name,
			building.name_short	AS building_name_short
		FROM room, building
		WHERE
			room.meta_default_data = 0 AND
			room.building = building.id
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub roomListInBuilding
{
	my $self = shift;
	my $building = shift;
	$building += 0; # force building to be numeric
	my $orderBy = shift || '';
	$orderBy = 'building.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	
	my $sth = $self->dbh->prepare(qq!
		SELECT
			room.*,
			building.name		AS building_name,
			building.name_short	AS building_name_short
		FROM room, building
		WHERE
			room.meta_default_data = 0 AND
			room.building = building.id AND
			room.building = ?
		ORDER BY $orderBy
	!);
	$sth->execute($building);
	return $sth->fetchall_arrayref({});
}

sub roomListBasic
{
	my $self = shift;
	my $sth = $self->dbh->prepare(q!
		SELECT 
			room.id, 
			room.name, 
			building.name AS building_name,
			building.name_short	AS building_name_short
		FROM room, building 
		WHERE 
			room.meta_default_data = 0 AND
			room.building = building.id 
		ORDER BY 
			room.meta_default_data DESC,
			building.name,
			room.name
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateRoom
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update room. No room record specified.\nError occured" unless ($record);
		
	my ($sth, $newId);
	
	if ($$record{'id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE room SET name = ?, building =?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateRoomUpdate($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This room may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$self->dbh->{AutoCommit} = 0;    # need to update room and row table together
		eval
		{
			$sth = $self->dbh->prepare(qq!INSERT INTO room (name, building, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
			$sth->execute($self->_validateRoomUpdate($record), $updateTime, $updateUser);
			$newId = $self->_lastInsertId('room');
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
	return $newId || $$record{'id'};
}

sub deleteRoom
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No room id specified.\nError occured" unless ($deleteId);
	
	my ($ret, $sth);
	$self->dbh->{AutoCommit} = 0;    # need to delete room and hidden rows together
	eval
	{
		$sth = $self->dbh->prepare(qq!DELETE FROM row WHERE hidden_row = 1 AND room = ?!);
		$sth->execute($deleteId);
		$sth = $self->dbh->prepare(qq!DELETE FROM room WHERE id = ?!);
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
	return $deleteId;
}

sub _validateRoomUpdate
{
	my ($self, $record) = @_;
	die "RMERR_INTERNAL: Unable to validate building. No building record specified.\nError occured" unless ($record);
	checkName($$record{'name'});
	checkNotes($$record{'notes'});
	return ($$record{'name'}, $$record{'building_id'}, $$record{'notes'});
}


##############################################################################
# Row Methods                                                                #  
##############################################################################

sub row
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			row.*,
			room.name			AS room_name,
			building.name		AS building_name,
			building.name_short	AS building_name_short
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

sub rowList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'building.name, room.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	# by default, order by building name and room name first
	$orderBy = $orderBy.', row.name' unless $orderBy eq 'row.name'; # default third ordering is row name
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			row.*,
			room.name			AS room_name,
			building.name		AS building_name,
			building.name_short	AS building_name_short
		FROM row, room, building 
		WHERE
			row.meta_default_data = 0 AND
			row.room = room.id AND
			room.building = building.id
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub rowListInRoom
{
	my ($self, $room) = @_;
	$room += 0; # force room to be numeric
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			row.*,
			room.name			AS room_name,
			building.name		AS building_name,
			building.name_short	AS building_name_short
		FROM row, room, building 
		WHERE
			row.meta_default_data = 0 AND
			row.room = room.id AND
			room.building = building.id AND
			row.room = ?
		ORDER BY row.room_pos
	!);
	$sth->execute($room);
	return $sth->fetchall_arrayref({});
}

sub rowListInRoomBasic
{
	my ($self, $room) = @_;
	$room += 0; # force room to be numeric
	my $sth = $self->dbh->prepare(qq!
		SELECT
			row.id,
			row.name
		FROM row
		WHERE
			row.meta_default_data = 0 AND
			row.room = ?
		ORDER BY row.name
	!);
	$sth->execute($room);
	return $sth->fetchall_arrayref({});
}

sub rowCountInRoom
{
	my ($self, $room) = @_;
	$room += 0; # force room to be numeric
	my $sth = $self->dbh->prepare(qq!
		SELECT
			count (*)
		FROM row
		WHERE
			row.meta_default_data = 0 AND
			row.room = ?
	!);
	$sth->execute($room);
	my $countRef = $sth->fetch;
	return $$countRef[0];
}

sub deleteRow
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No row id specified.\nError occured" unless ($deleteId);
	die "RMERR: This method is not yet supported.\nError occured";
	return $deleteId;
}

sub updateRow
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update row. No row record specified.\nError occured" unless ($record);
	
	my ($sth, $newId);
		
	if ($$record{'id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE row SET name = ?, room = ?, room_pos = ?, hidden_row = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateRowUpdate($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This row may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO row (name, room, room_pos, hidden_row, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateRowUpdate($record), $updateTime, $updateUser);
		$newId = $self->_lastInsertId('row');
	}
	return $newId || $$record{'id'};
}

sub _validateRowUpdate
{
	my ($self, $record) = @_;
	die "RMERR_INTERNAL: Unable to validate row. No row record specified.\nError occured" unless ($record);
	checkName($$record{'name'});
	checkNotes($$record{'notes'});
	return ($$record{'name'}, $$record{'room'}, $$record{'room_pos'}, $$record{'hidden_row'}, $$record{'notes'});
}


##############################################################################
# Rack Methods                                                               #  
##############################################################################

sub rack
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			rack.*,
			row.name			AS row_name,
			row.hidden_row		AS row_hidden,
			room.id				AS room,
			room.name			AS room_name,
			building.name		AS building_name, 
			building.name_short	AS building_name_short
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

sub rackCount
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT count(*) 
		FROM rack
		WHERE meta_default_data = 0
	!);
	$sth->execute();
	return ($sth->fetchrow_array)[0];
}

sub rackList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'building.name, room.name, row.name, rack.row_pos' unless $orderBy =~ /^[a-z_]+[\._][a-z_]+$/;	# by default, order by building name and room name first
	$orderBy = $orderBy.', rack.row_pos, rack.name' unless ($orderBy eq 'rack.row_pos, rack.name' or $orderBy eq 'rack.name'); # default third ordering is rack name
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			rack.*,
			row.name			AS row_name,
			row.hidden_row		AS row_hidden,
			room.id				AS room,
			room.name			AS room_name,
			building.name		AS building_name,
			building.name_short	AS building_name_short,
			count(device.id)	AS device_count,
			rack.size - COALESCE(SUM(hardware.size), 0)	AS free_space
		FROM rack, row, room, building
		LEFT OUTER JOIN device ON
			(rack.id = device.rack)
		LEFT OUTER JOIN hardware ON
			(hardware.id = device.hardware)
		WHERE
			rack.meta_default_data = 0 AND
			rack.row = row.id AND
			row.room = room.id AND
			room.building = building.id
		GROUP BY rack.id, rack.name, rack.row, rack.row_pos, rack.hidden_rack, rack.size, rack.notes, rack.meta_default_data, rack.meta_update_time, rack.meta_update_user, row.name, row.hidden_row, room.id, room.name, building.name, building.name_short
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub rackListInRoom
{
	my ($self, $room) = @_;
	$room += 0; # force room to be numeric
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			rack.*,
			row.name			AS row_name,
			row.hidden_row		AS row_hidden,
			room.id				AS room,
			room.name			AS room_name,
			building.name		AS building_name,
			building.name_short	AS building_name_short
		FROM rack, row, room, building 
		WHERE
			rack.meta_default_data = 0 AND
			rack.row = row.id AND
			row.room = room.id AND
			room.building = building.id AND
			row.room = ?
		ORDER BY rack.row, rack.row_pos
	!);
	$sth->execute($room);
	return $sth->fetchall_arrayref({});
}

sub rackListBasic
{
	my $self = shift;

	my $sth = $self->dbh->prepare(qq!
		SELECT
			rack.id,
			rack.name,
			rack.meta_default_data,
			room.name		AS room_name, 
			building.name	AS building_name,
			building.name_short	AS building_name_short
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

sub rackPhysical # This method is all rather inelegant and doesn't deal with racks numbered from the top
{
	my ($self, $rackid, $selectDev) = @_;
	$selectDev ||= -1; # not zero so we don't select empty positions
	my $devices = $self->deviceListInRack($rackid);

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
				$rackLayout[$position]{'is_selected'} = ($rackLayout[$position]{'id'} == $selectDev); # flag the selected device
				my $size = $$dev{'hardware_size'} || 0;
				while ($size > 1)
				{
					$position--;
					$size--;
					$rackLayout[$position] = {'rack_pos' => $position, 'id' => $$dev{'id'}, 'name' => $$dev{'name'}, 'hardware_size' => 0};
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
		$$r{'rack_id'} = $rackid; # include rack identifier in each entry - should review this when considering namespacing (see todo)
	}	
	
	@rackLayout = reverse @rackLayout unless RACKNUMBERINGTOP;  # racks are numbered from the bottom unless configured otherwise
	
	return \@rackLayout;
}

sub updateRack
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update rack. No rack record specified.\nError occured" unless ($record);
	
	my ($sth, $newId);
	
	# if no row is specified we need to use the default one for the room (lowest id)
	unless (defined $$record{'row'})
	{
		$sth = $self->dbh->prepare(qq!SELECT id FROM row WHERE room = ? ORDER BY id LIMIT 1!);
		$sth->execute($$record{'room'});
		$$record{'row'} = ($sth->fetchrow_array)[0];
		die "RMERR: Unable to update rack. Unable to determine row for rack.\nError occured" unless $$record{'row'};
	}

	# force row_pos to 0 until rows are supported
	$$record{'row_pos'} = 0 unless (defined $$record{'row_pos'});
	
	# hidden racks can't be created directly
	$$record{'hidden_rack'} = 0;
	
	if ($$record{'id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE rack SET name = ?, row = ?, row_pos = ?, hidden_rack = ?, size = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateRackUpdate($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This rack may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO rack (name, row, row_pos, hidden_rack, size, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateRackUpdate($record), $updateTime, $updateUser);
		$newId = $self->_lastInsertId('rack');
	}
	return $newId || $$record{'id'};
}

sub deleteRack
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No rack id specified.\nError occured" unless ($deleteId);
	my $sth = $self->dbh->prepare(qq!DELETE FROM rack WHERE id = ?!);
	my $ret = $sth->execute($deleteId);
	die "RMERR: Delete failed. This rack does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
	return $deleteId;
}

sub _validateRackUpdate
{
	my ($self, $record) = @_;
	die "RMERR_INTERNAL: Unable to validate rack. No rack record specified.\nError occured" unless ($record);
	checkName($$record{'name'});
	checkNotes($$record{'notes'});
	my $highestPos = $self->_highestUsedInRack($$record{'id'});
	if ($highestPos > $$record{'size'})
	{
		die "RMERR: You cannot reduce the rack size to $$record{'size'} U as there is a device at position $highestPos.\nError occured";
	}
	die "RMERR_INTERNAL: Rack sizes must be between 1 and ".MAXRACKSIZE." units.\nError occured" unless (($$record{'size'} > 0) && ($$record{'size'} < MAXRACKSIZE));
	return ($$record{'name'}, $$record{'row'}, $$record{'row_pos'}, $$record{'hidden_rack'}, $$record{'size'}, $$record{'notes'});
}

sub _highestUsedInRack
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			MAX(device.rack_pos + hardware.size - 1)
		FROM device, rack, hardware
		WHERE 
			device.rack = rack.id AND
			device.hardware = hardware.id AND
			rack.id = ?
	!);
	$sth->execute($id);
	return ($sth->fetchrow_array)[0];	
}

sub totalSizeRack
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT COALESCE(SUM(size), 0) 
		FROM rack; 
	!);
	$sth->execute();
	return ($sth->fetchrow_array)[0];	
}

##############################################################################
# Hardware Methods                                                           #  
##############################################################################

sub hardware
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT
			hardware.*,
			org.name 				AS manufacturer_name,
			org.meta_default_data	As manufacturer_meta_default_data
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

sub hardwareList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'hardware.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	
	my $sth = $self->dbh->prepare(qq!
		SELECT
			hardware.*,
			org.name 				AS manufacturer_name
		FROM hardware, org
		WHERE
			hardware.meta_default_data = 0 AND
			hardware.manufacturer = org.id
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub hardwareListBasic
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT
			hardware.id,
			hardware.name,
			hardware.meta_default_data,
			org.name 				AS manufacturer_name,
			org.meta_default_data	As manufacturer_meta_default_data
		FROM hardware, org
		WHERE hardware.manufacturer = org.id
		ORDER BY 
			hardware.meta_default_data DESC,
			hardware.name
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateHardware
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update hardware. No hardware record specified.\nError occured" unless ($record);
	
	my ($sth, $newId);
	
	if ($$record{'id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE hardware SET name = ?, manufacturer =?, size = ?, image = ?, support_url = ?, spec_url = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateHardwareUpdate($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This hardware may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO hardware (name, manufacturer, size, image, support_url, spec_url, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateHardwareUpdate($record), $updateTime, $updateUser);
		$newId = $self->_lastInsertId('hardware');
	}
	return $newId || $$record{'id'};
}

sub deleteHardware
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No hardware id specified.\nError occured" unless ($deleteId);
	my $sth = $self->dbh->prepare(qq!DELETE FROM hardware WHERE id = ?!);
	my $ret = $sth->execute($deleteId);
	die "RMERR: Delete failed. This hardware does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
	return $deleteId;
}

sub _validateHardwareUpdate
{
	my ($self, $record) = @_;
	die "RMERR_INTERNAL: Unable to validate hardware. No hardware record specified.\nError occured" unless ($record);

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

sub hardwareDeviceCount
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			hardware.name AS hardware, 
			org.name AS manufacturer,
			COUNT(device.id) AS num_devices,
			hardware.meta_default_data AS hardware_meta_default_data,
			org.meta_default_data AS hardware_manufacturer_meta_default_data			
		FROM device, hardware, org 
		WHERE 
			device.hardware = hardware.id AND
			hardware.manufacturer = org.id 
		GROUP BY hardware.name, org.name, hardware.meta_default_data, org.meta_default_data
		ORDER BY num_devices DESC
		LIMIT 10;
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

##############################################################################
# Operating System Methods                                                   #  
##############################################################################

sub os
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			os.*,
			org.name 				AS manufacturer_name,
			org.meta_default_data	As manufacturer_meta_default_data
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

sub osList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'os.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			os.*,
			org.name 			AS manufacturer_name 
		FROM os, org 
		WHERE 
			os.meta_default_data = 0 AND
			os.manufacturer = org.id
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateOs
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update OS. No OS record specified.\nError occured" unless ($record);

	my ($sth, $newId);
	
	if ($$record{'id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE os SET name = ?, manufacturer = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateOsUpdate($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This OS may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO os (name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateOsUpdate($record), $updateTime, $updateUser);
		$newId = $self->_lastInsertId('os');
	}
	return $newId || $$record{'id'};
}

sub deleteOs
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No OS id specified.\nError occured" unless ($deleteId);
	my $sth = $self->dbh->prepare(qq!DELETE FROM os WHERE id = ?!);
	my $ret = $sth->execute($deleteId);
	die "RMERR: Delete failed. This OS does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
	return $deleteId;
}

sub _validateOsUpdate
{
	my ($self, $record) = @_;
	die "RMERR: You must specify a name for the operating system.\nError occured" unless (length($$record{'name'}) > 1);
	die "RMERR: Names must be less than ".MAXSTRING." characters.\nError occured" unless (length($$record{'name'}) <= MAXSTRING);
	# no validation for $$record{'manufacturer_id'} - foreign key constraints will catch
	die "RMERR: Notes cannot exceed '.MAXNOTE.' characters.\nError occured" unless (length($$record{'notes'}) <= MAXNOTE);
	return ($$record{'name'}, $$record{'manufacturer_id'}, $$record{'notes'});
}

sub osDeviceCount
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			os.name AS os, 
			device.os_version AS version,
			COUNT(device.id) AS num_devices,
			os.meta_default_data AS os_meta_default_data
		FROM device, os, org 
		WHERE 
			device.os = os.id AND
			os.manufacturer = org.id 
		GROUP BY os.name, device.os_version, os.meta_default_data
		ORDER BY num_devices DESC
		LIMIT 10;
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

##############################################################################
# Organisation Methods                                                       #  
##############################################################################

sub org
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

sub orgList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'org.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;
	
	my $sth = $self->dbh->prepare(qq!
		SELECT org.*
		FROM org
		WHERE org.meta_default_data = 0
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateOrg
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update org. No org record specified.\nError occured" unless ($record);

	my ($sth, $newId);
	
	if ($$record{'id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE org SET name = ?, account_no = ?, customer = ?, software = ?, hardware = ?, descript = ?, home_page = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateOrgUpdate($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This org may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO org (name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateOrgUpdate($record), $updateTime, $updateUser);
		$newId = $self->_lastInsertId('org');
	}
	return $newId || $$record{'id'};
}

sub deleteOrg
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No org id specified.\nError occured" unless ($deleteId);
	my $sth = $self->dbh->prepare(qq!DELETE FROM org WHERE id = ?!);
	my $ret = $sth->execute($deleteId);
	die "RMERR: Delete failed. This org does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
	return $deleteId;
}

sub _validateOrgUpdate
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

sub customerDeviceCount
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			org.name AS customer, 
			COUNT(device.id) AS num_devices 
		FROM device, org 
		WHERE device.customer = org.id 
		GROUP BY org.name 
		ORDER BY num_devices DESC
		LIMIT 10;
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

##############################################################################
# Domain Methods                                                             #  
##############################################################################

sub domain
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

sub domainList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'domain.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;
	
	my $sth = $self->dbh->prepare(qq!
		SELECT domain.*
		FROM domain 
		WHERE domain.meta_default_data = 0
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateDomain
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update domain. No domain record specified.\nError occured" unless ($record);

	my ($sth, $newId);
	
	if ($$record{'id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE domain SET name = ?, descript = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateDomainUpdate($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This domain may have been removed before the update occured.\nError occured" if ($ret eq '0E0');		
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO domain (name, descript, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateDomainUpdate($record), $updateTime, $updateUser);
		$newId = $self->_lastInsertId('domain');
	}
	return $newId || $$record{'id'};
}

sub deleteDomain
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No domain id specified.\nError occured" unless ($deleteId);
	my $sth = $self->dbh->prepare(qq!DELETE FROM domain WHERE id = ?!);
	my $ret = $sth->execute($deleteId);
	die "RMERR: Delete failed. This domain does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
	return $deleteId;
}

sub _validateDomainUpdate # Should we remove or warn on domains beginning with . ?
{
	my ($self, $record) = @_;
	die "RMERR: You must specify a name for the domain.\nError occured" unless (length($$record{'name'}) > 1);
	die "RMERR: Names must be less than ".MAXSTRING." characters.\nError occured" unless (length($$record{'name'}) <= MAXSTRING);
	die "RMERR: Descriptions cannot exceed ".MAXSTRING." characters.\nError occured" unless (length($$record{'descript'}) <= MAXSTRING);
	die "RMERR: Notes cannot exceed ".MAXNOTE." characters.\nError occured" unless (length($$record{'notes'}) <= MAXNOTE);
	return ($$record{'name'}, $$record{'descript'}, $$record{'notes'});
}


##############################################################################
# Device Methods                                                             #  
##############################################################################

sub device
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			device.*, 
			rack.name 					AS rack_name,
			row.name					AS row_name,
			row.id						AS row_id,
			room.name					AS room_name,
			room.id						AS room_id,
			building.name				AS building_name,
			building.name_short			AS building_name_short,			
			building.id					AS building_id,	
			building.meta_default_data	AS building_meta_default_data,
			hardware.name 				AS hardware_name,
			hardware.size 				AS hardware_size,
			hardware.meta_default_data	AS hardware_meta_default_data,
			hardware_manufacturer.name	AS hardware_manufacturer_name,
			hardware_manufacturer.meta_default_data AS hardware_manufacturer_meta_default_data,
			role.name 					AS role_name, 
			role.meta_default_data		AS role_meta_default_data,
			os.name 					AS os_name,
			os.meta_default_data		AS os_meta_default_data,
			customer.name 				AS customer_name,
			customer.meta_default_data	AS customer_meta_default_data,
			service.name 				AS service_name,
			service.meta_default_data	AS service_meta_default_data,
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

sub deviceCount
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT count(*) 
		FROM device
		WHERE meta_default_data = 0
	!);
	$sth->execute();
	return ($sth->fetchrow_array)[0];
}

sub deviceList
{
	my $self = shift;
	my $orderBy = shift || '';
	my $filters = shift || {};
	my $filterBy ='';
	
	for my $f (keys %$filters)
	{
		$filterBy .= " AND $f=".$$filters{"$f"};
	}
	
	$orderBy = 'device.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;

	# ensure meta_default entries appear last - need a better way to do this
	$orderBy = 'room.meta_default_data, '.$orderBy if ($orderBy =~ /^room.name/);	
	$orderBy = 'rack.meta_default_data, '.$orderBy if ($orderBy =~ /^rack.name/);	
	$orderBy = 'role.meta_default_data, '.$orderBy if ($orderBy =~ /^role.name/);	
	$orderBy = 'hardware.meta_default_data, '.$orderBy if ($orderBy =~ /^hardware.name/);	
	$orderBy = 'os.meta_default_data, '.$orderBy.', device.os_version' if ($orderBy =~ /^os.name/);	
	$orderBy = 'customer.meta_default_data, '.$orderBy if ($orderBy =~ /^customer.name/);	
	$orderBy = 'service.meta_default_data, '.$orderBy if ($orderBy =~ /^service.name/);	
	
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			device.*, 
			rack.name 					AS rack_name,
			row.name					AS row_name,
			row.id						AS row_id,
			room.name					AS room_name,
			room.id						AS room_id,
			building.name				AS building_name,
			building.name_short			AS building_name_short,			
			building.id					AS building_id,	
			building.meta_default_data	AS building_meta_default_data,
			hardware.name 				AS hardware_name,
			hardware.size 				AS hardware_size,
			hardware.meta_default_data	AS hardware_meta_default_data,
			hardware_manufacturer.name	AS hardware_manufacturer_name,
			hardware_manufacturer.meta_default_data	AS hardware_manufacturer_meta_default_data,
			role.name 					AS role_name, 
			os.name 					AS os_name, 
			customer.name 				AS customer_name,
			service.name 				AS service_name,
			domain.name					AS domain_name,
			domain.meta_default_data	AS domain_meta_default_data
		FROM device, rack, row, room, building, hardware, org hardware_manufacturer, role, os, org customer, service, domain 
		WHERE 
			device.meta_default_data = 0 AND
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
			$filterBy
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub deviceListInRack
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
			hardware.meta_default_data	AS hardware_meta_default_data,
			hardware_manufacturer.name	AS hardware_manufacturer_name,
			hardware_manufacturer.meta_default_data	AS hardware_manufacturer_meta_default_data,
			hardware.size				AS hardware_size,
			domain.name					AS domain_name,
			domain.meta_default_data	AS domain_meta_default_data
		FROM
			device, rack, row, room, building, hardware, org hardware_manufacturer, domain
		WHERE
			device.meta_default_data = 0 AND
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
	return $sth->fetchall_arrayref({});		
}

sub deviceListUnracked # consider merging this with existing device method
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			device.*,
			rack.name 					AS rack_name,
			building.meta_default_data	AS building_meta_default_data,
			hardware.name 				AS hardware_name,
			hardware.meta_default_data	AS hardware_meta_default_data,
			hardware_manufacturer.name	AS hardware_manufacturer_name,
			hardware_manufacturer.meta_default_data	AS hardware_manufacturer_meta_default_data,
			hardware.size				AS hardware_size,
			domain.name					AS domain_name,
			domain.meta_default_data	AS domain_meta_default_data,
			role.name 					AS role_name,
			os.name 					AS os_name
			FROM
			device, rack, row, room, building, hardware, org hardware_manufacturer, domain, role, os
		WHERE
			device.meta_default_data = 0 AND
			building.meta_default_data <> 0 AND
			device.rack = rack.id AND 
			rack.row = row.id AND
			row.room = room.id AND
			room.building = building.id AND				
			device.hardware = hardware.id AND
			hardware.manufacturer = hardware_manufacturer.id AND
			device.domain = domain.id AND
			device.role = role.id AND
			device.os = os.id
		ORDER BY device.meta_default_data, device.name
	!);
	
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateDevice
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update device. No building device specified.\nError occured" unless ($record);
	
	my ($sth, $newId);

	if ($$record{'id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE device SET name = ?, domain = ?, rack = ?, rack_pos = ?, hardware = ?, serial_no = ?, asset_no = ?, purchased = ?, os = ?, os_version = ?, customer = ?, service = ?, role = ?, in_service = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateDeviceInput($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This device may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO device (name, domain, rack, rack_pos, hardware, serial_no, asset_no, purchased, os, os_version, customer, service, role, in_service, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateDeviceInput($record), $updateTime, $updateUser);
		$newId = $self->_lastInsertId('device');
	}
	return $newId || $$record{'id'};
}

sub deleteDevice
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No device id specified.\nError occured" unless ($deleteId);
	my $sth = $self->dbh->prepare(qq!DELETE FROM device WHERE id = ?!);
	my $ret = $sth->execute($deleteId);
	die "RMERR: Delete failed. This device does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
	return $deleteId;
}

sub _validateDeviceInput # doesn't check much at present
{
	my ($self, $record) = @_;
	die "RMERR_INTERNAL: Unable to validate device. No device record specified.\nError occured" unless ($record);
	checkName($$record{'name'});
	checkNotes($$record{'notes'});
	$$record{'purchased'} = checkDate($$record{'purchased'}); # check date and coerce to YYYY-MM-DD format
	
	# normalise in service value so it can be stored as an integer
	$$record{'in_service'} = $$record{'in_service'} ? 1 : 0;
	
	# check if we have a meta default location if so set rack position to blank, otherwise check we have a valid rack position
	my $rack = $self->rack($$record{'rack'});
	if ($$rack{'meta_default_data'})
	{
		$$record{'rack_pos'} = '';
	}
	else # location is in a real rack
	{
		# check we have a position
		die "RMERR: You need to specify a Rack Position.\nError occured" unless (length($$record{'rack_pos'}) > 0);
		
		# get the size of this hardware
		my $hardware = $self->hardware($$record{'hardware'});
		my $hardwareSize = $$hardware{'size'};
		
	 	unless ($$record{'rack_pos'} > 0 and $$record{'rack_pos'} + $$hardware{'size'} - 1 <= $$rack{'size'})
		{
			die "RMERR: The device '".$$record{'name'}."' cannot fit at that location. This rack is ".$$rack{'size'}." U in height. This device is $hardwareSize U and you placed it at position ".$$record{'rack_pos'}.".\nError occured";
		}
		
		# ensure the location doesn't overlap any other devices in this rack
		
		# get the layout of this rack
		my $rackLayout = $self->rackPhysical($$record{'rack'});	
		
		# quick and dirty check for overlap, consider each position occupied by the new device and check it's empty
		# doesn't assume the rackPhyiscal method returns in a particular order
		for ($$record{'rack_pos'} .. $$record{'rack_pos'} + $hardwareSize - 1)
		{
			my $pos = $_;
			for my $r (@$rackLayout)
			{
				die "RMERR: Cannot put the device '".$$record{'name'}."' here (position ".$$record{'rack_pos'}." in rack ".$$rack{'name'}.") because it overlaps with the device '".$$r{'name'}."'.\nError occured" if ($$r{'rack_pos'} == $pos and $$r{'name'} and ($$r{'id'} ne $$record{'id'}));
			}
		}
	}
	
	return ($$record{'name'}, $$record{'domain'}, $$record{'rack'}, $$record{'rack_pos'}, $$record{'hardware'}, $$record{'serial_no'}, $$record{'asset_no'}, $$record{'purchased'}, $$record{'os'}, $$record{'os_version'}, $$record{'customer'}, $$record{'service'}, $$record{'role'}, $$record{'in_service'}, $$record{'notes'});
}

sub totalSizeDevice
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT COALESCE(SUM(size), 0) 
		FROM hardware, device 
		WHERE device.hardware = hardware.id;
	!);
	$sth->execute();
	return ($sth->fetchrow_array)[0];	
}


##############################################################################
# Role Methods                                                               #  
##############################################################################

sub role
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

sub roleList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'role.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	
	my $sth = $self->dbh->prepare(qq!
		SELECT role.* 
		FROM role 
		WHERE role.meta_default_data = 0
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateRole
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update role. No role record specified.\nError occured" unless ($record);

	my ($sth, $newId);
	
	if ($$record{'id'}) # if id is supplied peform an update
	{	
		$sth = $self->dbh->prepare(qq!UPDATE role SET name = ?, descript = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateRoleUpdate($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This role may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO role (name, descript, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateDomainUpdate($record), $updateTime, $updateUser);
		$newId = $self->_lastInsertId('role');
	}
	return $newId || $$record{'id'};
}

sub deleteRole
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No role id specified.\nError occured" unless ($deleteId);
	my $sth = $self->dbh->prepare(qq!DELETE FROM role WHERE id = ?!);
	my $ret = $sth->execute($deleteId);
	die "RMERR: Delete failed. This role does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
	return $deleteId;
}

sub _validateRoleUpdate
{
	my ($self, $record) = @_;
	die "RMERR: You must specify a name for the role.\nError occured" unless (length($$record{'name'}) > 1);
	die "RMERR: Names must be less than ".MAXSTRING." characters.\nError occured" unless (length($$record{'name'}) <= MAXSTRING);
	die "RMERR: Descriptions cannot exceed ".MAXSTRING." characters.\nError occured" unless (length($$record{'desc'}) <= MAXSTRING);
	die "RMERR: Notes cannot exceed ".MAXNOTE." characters.\nError occured" unless (length($$record{'notes'}) <= MAXNOTE);
	return ($$record{'name'}, $$record{'descript'}, $$record{'notes'});
}

sub roleDeviceCount
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT 
			role.name AS role, 
			COUNT(device.id) AS num_devices 
		FROM device, role 
		WHERE device.role = role.id 
		GROUP BY role.name 
		ORDER BY num_devices DESC
		LIMIT 10;
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

##############################################################################
# Service Level Methods                                                      #  
##############################################################################

sub service
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

sub serviceList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'service.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;	
	my $sth = $self->dbh->prepare(qq!
		SELECT service.* 
		FROM service 
		WHERE service.meta_default_data = 0
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub updateService
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update service level. No service level record specified.\nError occured" unless ($record);

	my ($sth, $newId);
	
	if ($$record{'id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE service SET name = ?, descript = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateServiceUpdate($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This service level may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO service (name, descript, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateServiceUpdate($record), $updateTime, $updateUser);
		$newId = $self->_lastInsertId('service');
	}
	return $newId || $$record{'id'};
}

sub deleteService
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No service level id specified.\nError occured" unless ($deleteId);
	my $sth = $self->dbh->prepare(qq!DELETE FROM service WHERE id = ?!);
	my $ret = $sth->execute($deleteId);
	die "RMERR: Delete failed. This service level does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
	return $deleteId;
}

sub _validateServiceUpdate
{
	my ($self, $record) = @_;
	die "RMERR: You must specify a name for the service level.\nError occured" unless (length($$record{'name'}) > 1);
	die "RMERR: Names must be less than ".MAXSTRING." characters.\nError occured" unless (length($$record{'name'}) <= MAXSTRING);
	die "RMERR: Descriptions cannot exceed ".MAXSTRING." characters.\nError occured" unless (length($$record{'desc'}) <= MAXSTRING);
	die "RMERR: Notes cannot exceed ".MAXNOTE." characters.\nError occured" unless (length($$record{'notes'}) <= MAXNOTE);
	return ($$record{'name'}, $$record{'descript'}, $$record{'notes'});
}


##############################################################################
# Application Methods                                                        #  
##############################################################################

sub app
{
	my ($self, $id) = @_;
	die "RMERR: Unable to retrieve app. No app id specified.\nError occured" unless ($id);
	my $sth = $self->dbh->prepare(qq!
		SELECT app.* 
		FROM app 
		WHERE id = ?
	!);
	$sth->execute($id);	
	my $app = $sth->fetchrow_hashref('NAME_lc');
	die "RMERR: No such app id.\nError occured" unless defined($$app{'id'});
	return $app;
}

sub appCount
{
	my $self = shift;
	my $sth = $self->dbh->prepare(qq!
		SELECT count(*) 
		FROM app 
		WHERE meta_default_data = 0
	!);
	$sth->execute();
	return ($sth->fetchrow_array)[0];
}

sub appList
{
	my $self = shift;
	my $orderBy = shift || '';
	$orderBy = 'app.name' unless $orderBy =~ /^[a-z_]+\.[a-z_]+$/;
	$orderBy = $orderBy.', app.name' unless $orderBy eq 'app.name';# default second ordering is name
	my $sth = $self->dbh->prepare_cached(qq!
		SELECT app.* 
		FROM app
		WHERE meta_default_data = 0
		ORDER BY $orderBy
	!);
	$sth->execute();
	return $sth->fetchall_arrayref({});
}

sub appDevicesUsedList
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare_cached(qq!
		SELECT
			device.id			AS device_id,
		 	device.name			AS device_name, 
			app.name			AS app_name,
			app_relation.name 	AS app_relation_name,
			domain.name			AS domain_name,
			domain.meta_default_data	AS domain_meta_default_data
		FROM
			device, app_relation, device_app, app, domain 
		WHERE
		 	device_app.app = app.id AND 
			device_app.device = device.id AND 
			device_app.relation = app_relation.id AND
			device.domain = domain.id AND 
			app.id = ?
	!);
	$sth->execute($id);
	return $sth->fetchall_arrayref({});
}

sub appOnDeviceList
{
	my ($self, $id) = @_;
	my $sth = $self->dbh->prepare_cached(qq!
		SELECT DISTINCT
			app.id				AS app_id,
			app.name			AS app_name
		FROM
			device, app_relation, device_app, app 
		WHERE
		 	device_app.app = app.id AND 
			device_app.device = device.id AND 
			device_app.relation = app_relation.id AND
			device.id = ?
		ORDER BY
			app.name
	!);
	$sth->execute($id);
	return $sth->fetchall_arrayref({});	
}

sub updateApp
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	die "RMERR: Unable to update app. No app record specified.\nError occured" unless ($record);
	
	my ($sth, $newId);

	if ($$record{'id'})
	{	
		$sth = $self->dbh->prepare(qq!UPDATE app SET name = ?, descript = ?, notes = ?, meta_update_time = ?, meta_update_user = ? WHERE id = ?!);
		my $ret = $sth->execute($self->_validateAppUpdate($record), $updateTime, $updateUser, $$record{'id'});
		die "RMERR: Update failed. This app may have been removed before the update occured.\nError occured" if ($ret eq '0E0');
	}
	else
	{
		$sth = $self->dbh->prepare(qq!INSERT INTO app (name, descript, notes, meta_update_time, meta_update_user) VALUES(?, ?, ?, ?, ?)!);
		$sth->execute($self->_validateAppUpdate($record), $updateTime, $updateUser);
		$newId = $self->_lastInsertId('app');
	}
	return $newId || $$record{'id'};
}

sub deleteApp
{
	my ($self, $updateTime, $updateUser, $record) = @_;
	my $deleteId = (ref $record eq 'HASH') ? $$record{'id'} : $record;
	die "RMERR: Delete failed. No app id specified.\nError occured" unless ($deleteId);
	my $sth = $self->dbh->prepare(qq!DELETE FROM app WHERE id = ?!);
	my $ret = $sth->execute($deleteId);
	die "RMERR: Delete failed. This app does not currently exist, it may have been removed already.\nError occured" if ($ret eq '0E0');
	return $deleteId;
}

sub _validateAppUpdate
{
	my ($self, $record) = @_;
	die "RMERR_INTERNAL: Unable to validate app. No app record specified.\nError occured" unless ($record);
	checkName($$record{'name'});
	checkNotes($$record{'notes'});
	return ($$record{'name'}, $$record{'descript'}, $$record{'notes'});
}

1;

=head1 NAME

RackMonkey::Engine - A DBI-based backend for Rackmonkey

=head1 SYNOPSIS

 use RackMonkey::Engine;

 my $dbh = DBI->connect('dbi:SQLite:dbname=/data/rack/rack.db', '', '');
 my $engine = new RackMonkey::Engine($dbh);
 my $org = $engine->org(1);
 print 'The org with id 1 has the name: '.$$org{'name'};

=head1 DESCRIPTION

RackMonkey::Engine sits between the RackMonkey application and the DBI.
RackMonkey::Engine abstracts the database implementation to provide a simple
API for querying and manipulating RackMonkey objects such as buildings, racks,
devices, and organisations. At present the Engine works correctly with
SQLite v3 and Postgres v8. 

By overriding methods in the Engine, other sources of information may be
updated or incorporated into RackMonkey. For example, customers might be
stored in a separate database, or you may wish to update a ticketing system
when a device is moved to another rack. For more information on getting
RackMonkey working with other applications, see the Developer Guide.

The rest of this document covers the RackMonkey::Engine methods, organised by
the 'type' of thing they operate on:

 Common (applicable to all)
 Building
 Room
 Row
 Rack
 Hardware
 Operating System
 Organisation
 Domain
 Device
 Role
 Service Level
 Application

=head1 COMMON METHODS

The following methods are generic and don't apply to a particular type of
RackMonkey entry.

 new ($dbh)
 entryBasic($id, $table)
 listBasic($table)
 listBasicMeta($table)
 performAct() 

=head2 new($dbh)

Create a new RackMonkey::Engine object and connect it to the database handle
identified by $dbh. For example:

	my $dbh = DBI->connect(DBDCONNECT, DBUSER, DBPASS);
	my $backend = new RackMonkey::Engine($dbh);

At present RackMonkey works with SQLite v3 and Postgres v8 databases. Using
database handles from other databases will produce undefined results.

=head1 BUILDING METHODS

 building($id)
 buildingCount()
 buildingList([$orderBy])
 updateBuilding($updateTime, $updateUser, $record)
 deleteBuilding($updateTime, $updateUser, $record)

=head2 building($id)

Gets a hash reference to one building specified by $id. If there is no such
building the library dies.

=head2 buildingCount()

Returns the number of real buildings stored in RackMonkey. Meta buildings
(such as 'unknown') are not counted.

=head2 buildingList([$orderBy])

Gets a list of all buildings ordered by the property $orderBy. If $orderBy is
not specified, buildings are ordered by their name (but with default data,
such as 'unknown', last in the list). If no buildings exist the returned list
will be empty. Returns a reference to an array of hash references. One hash
reference per building.

=head2 updateBuilding($updateTime, $updateUser, $record)

Updates or creates a building entry based on the hash ref $record. If
$$record{'id'} is specified an update will be performed, otherwise a new
building will be created. $updateTime and $updateUser set the update time and
user associated with this update. Both are strings, and may be empty. If the
engine tries to update a record, but no record is updated, the Engine dies.
Returns the id of the updated or created building.

=head2 deleteBuilding($self, $updateTime, $updateUser, $record)

Deletes the building whose id identified by $record. deleteBuilding checks
whether the record is a hash ref, and if so uses $$record{'id'} as the id,
otherwise $record is taken to be the id. Support for hash refs allows 
deleteBuilding to be called with the same data as an update. If no such
building exists or the delete fails the library dies. $updateTime and 
$updateUser set the update time and user associated with this delete; at
present they are disguarded.


=head1 ROOM METHODS

 room($id)
 roomCount()
 roomList([$orderBy])
 roomListInBuilding($building [, $orderBy]) 
 roomListBasic()
 updateRoom($updateTime, $updateUser, $record)
 deleteRoom($updateTime, $updateUser, $record)

=head2 room($id)

Gets a hash reference to one room specified by $id. If there is no such room
the engine dies.

=head2 roomCount()

Returns the number of real rooms stored in RackMonkey. Meta rooms (such as
'unknown') are not counted.

=head2 roomList([$orderBy])

Gets a list of all rooms ordered by the property $orderBy. If $orderBy is not
specified, rooms are ordered by their building, then their name (but with
default data, such as 'unknown', last in the list). If no rooms exist the
returned list will be empty. Returns a reference to an array of hash
references. One hash reference per room.

=head2 roomListInBuilding($building [, $orderBy])

As for roomList, but limits rooms returned to those in the building 
identified by the id $building. If the building doesn't exist, or is empty of
rooms, the returned list will be empty.

=head2 roomListBasic()

Because rooms reside in buildings, the common listBasic() is often not what 
you want. roomListBasic works just like listBasic(), but returns the
building name too. If no rooms exist the returned list will be empty.

=head2 updateRoom($updateTime, $updateUser, $record)

Updates or creates a room entry based on the hash ref $record. If 
$$record{'id'} is specified an update will be performed, otherwise a new room
will be created. $updateTime and $updateUser set the update time and user
associated with this update. Both are strings, and may be empty. If the engine
tries to update a record, but no record is updated, the Engine dies. Returns
the id of the updated or created building.

=head2 deleteRoom($updateTime, $updateUser, $record)

Deletes the room whose id identified by $record. deleteRoom checks whether the
record is a hash ref, and if so uses $$record{'id'} as the id, otherwise 
$record is taken to be the id. Support for hash refs allows deleteRoom
to be called with the same data as an update. If no such room exists or the 
delete fails the library dies. $updateTime and $updateUser set the update time
and user associated with this delete; at present they are disguarded.

 
=head1 BUGS

You can view and report bugs at http://www.rackmonkey.org

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

=head1 AUTHOR

Will Green - http://flux.org.uk

=head1 SEE ALSO

http://www.rackmonkey.org

=cut
