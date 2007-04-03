------------------------------------------------------------------------
-- RackMonkey - Know Your Racks - http://www.rackmonkey.org
-- Version 1.2.%BUILD%
-- (C)2007 Will Green (wgreen at users.sourceforge.net)
-- Sample content for RackMonkey database
------------------------------------------------------------------------

-- sample organisations
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(11, 'Apple', 		NULL, 0, 1, 1, 'Apple', 'http://www.apple.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(12, 'Canonical', 	NULL, 0, 1, 0, 'Canonical', 'http://www.canonical.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(13, 'Cisco', 		NULL, 0, 1, 1, 'Cisco Systems', 'http://www.cisco.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(14, 'Dell', 		NULL, 0, 0, 1, 'Dell', 'http://www.dell.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(15, 'Foundry', 		NULL, 0, 0, 1, 'Foundry Networks', 'http://www.foundrynet.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(16, 'FreeBSD', 		NULL, 0, 1, 0, 'FreeBSD Project', 'http://www.freebsd.org', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(17, 'HP', 			NULL, 0, 1, 1, 'Hewlett Packard', 'http://www.hp.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(18, 'IBM', 			NULL, 0, 1, 1, 'International Business Machines', 'http://www.ibm.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(19, 'Juniper', 		NULL, 0, 1, 1, 'Juniper Networks', 'http://www.juniper.net', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(20, 'Lantronix', 	NULL, 0, 0, 1, 'Lantronix', 'http://www.lantronix.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(21, 'Lenovo', 		NULL, 0, 0, 1, 'Lenovo', 'http://www.lenovo.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(22, 'Microsoft', 	NULL, 0, 1, 0, 'Microsoft', 'http://www.microsoft.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(23, 'NetApp', 		NULL, 0, 0, 1, 'Network Appliance', 'http://www.netapp.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(24, 'NetBSD', 		NULL, 0, 1, 0, 'NetBSD Foundation', 'http://www.netbsd.org', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(25, 'Novell', 		NULL, 0, 1, 0, 'Novell', 'http://www.novell.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(26, 'OpenBSD', 		NULL, 0, 1, 0, 'OpenBSD Project', 'http://www.openbsd.org', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(27, 'Red Hat', 		NULL, 0, 1, 0, 'Red Hat', 'http://www.redhat.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(28, 'Slackware',	NULL, 0, 1, 0, 'Slackware Linux Project', 'http://www.slackware.org', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(29, 'SPI', 			NULL, 0, 1, 0, 'Software in the Public Interest', 'http://www.spi-inc.org', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO org (id, name, account_no, customer, software, hardware, descript, home_page, notes, meta_update_time, meta_update_user) VALUES(30, 'Sun', 			NULL, 0, 1, 1, 'Sun Microsystems', 'http://www.sun.com', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');

-- sample operating systems
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(11, 'AIX', 				18, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(12, 'Debian', 			29, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(13, 'RHEL', 				27, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(14, 'FreeBSD', 			16, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(15, 'HP-UX', 				17, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(16, 'IOS', 				13, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(17, 'Mac OS X Server',	11, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(18, 'NetBSD', 			24, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(19, 'OpenBSD',			26, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(20, 'Slackware Linux',	28, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(21, 'Solaris', 			30, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(22, 'SUSE Linux', 		25, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(23, 'Ubuntu Linux', 		12, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO os (id, name, manufacturer, notes, meta_update_time, meta_update_user) VALUES(24, 'Windows Server', 	22, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');

-- sample hardware
INSERT INTO hardware (id, name, manufacturer, size, image, support_url, spec_url, notes, meta_update_time, meta_update_user) VALUES(11, 'Catalyst 3560', 		13, 1, NULL, 'http://www.cisco.com/en/US/products/hw/switches/ps5528/tsd_products_support_series_home.html', 'http://www.cisco.com/en/US/products/hw/switches/ps5528/products_data_sheet09186a00801f3d7d.html', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO hardware (id, name, manufacturer, size, image, support_url, spec_url, notes, meta_update_time, meta_update_user) VALUES(12, 'eServer p5 550', 		18, 4, NULL, 'http://www.ibm.com/servers/eserver/support/unixservers/syp5/solvinghwonly.html', 'http://www.ibm.com/servers/eserver/pseries/hardware/entry/550_specs.html', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO hardware (id, name, manufacturer, size, image, support_url, spec_url, notes, meta_update_time, meta_update_user) VALUES(13, 'Fire T2000', 			30, 2, NULL, 'http://sunsolve.sun.com/handbook_pub/Systems/SunFireT2000/SunFireT2000.html', 'http://sunsolve.sun.com/handbook_pub/Systems/SunFireT2000/spec.html', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO hardware (id, name, manufacturer, size, image, support_url, spec_url, notes, meta_update_time, meta_update_user) VALUES(14, 'PowerEdge 2850', 		14, 2, NULL, 'http://support.dell.com/support/edocs/systems/pe2850/en/', NULL, 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO hardware (id, name, manufacturer, size, image, support_url, spec_url, notes, meta_update_time, meta_update_user) VALUES(15, 'Xserve G5', 			11, 1, NULL, 'http://www.apple.com/support/xserve/', 'http://support.apple.com/specs/xserve/Xserve_G5.html', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');

-- sample roles
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(11, 'App Server', 			'Application Server', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(12, 'AV Encoder', 			'Audio/Video Encoder', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(13, 'Data Backup', 			'Data Backup', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(14, 'Data Storage', 		'Data Storage', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(15, 'Database Server', 		'Database Server', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(16, 'Dev Server', 			'Development Server', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(17, 'FC Switch', 			'Fibre Channel Switch', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(18, 'File Server', 			'File Server', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(19, 'Human Interface', 		'Monitor/Keyboard etc.', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(20, 'KVM', 'KVM Server', 	'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(21, 'Monitoring', 			'Systems Monitoring', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(22, 'Physical Storage', 	'Storage for Physical Items', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(23, 'Power', 				'Electrical power infrastructure', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(24, 'Router', 				'Network Router', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(25, 'Streaming Server', 	'Streaming Audio/Video Server', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(26, 'Switch', 				'Network Switch', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(27, 'Terminal Server',		'Terminal Server', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(28, 'Unused',				'Unused', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');
INSERT INTO role (id, name, descript, notes, meta_update_time, meta_update_user) VALUES(29, 'Web Server',			'Web Server', 'Sample data included with RackMonkey.', '2007-01-01 00:00:00', 'install');

-- The inclusion of a company or product in this file does not consitute an endorement by the author.
-- All trademarks are the property of their respective owners.
