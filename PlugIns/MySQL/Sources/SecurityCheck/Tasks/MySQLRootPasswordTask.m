/*
 
 XAMPP
 Copyright (C) 2009 by Apache Friends
 
 Authors of this file:
 - Christian Speich <kleinweby@apachefriends.org>
 
 This file is part of XAMPP.
 
 XAMPP is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 XAMPP is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with XAMPP.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#import "MySQLRootPasswordTask.h"
#import "MySQLPlugIn.h"
#import "MySQLModule.h"
#include <mysql/mysql.h>

@interface MySQLRootPasswordTask(PRIVAT)

- (BOOL) changePasswordInMySQL;
- (BOOL) updatePMAConfig;

@end

@implementation MySQLRootPasswordTask

- (void) dealloc
{
	[self setPassword:Nil];
	
	[super dealloc];
}


- (NSString*) password
{
	return _password;
}

- (void) setPassword:(NSString*)password
{
	[_password release];
	_password = [password retain];
}

- (NSString*) localizedTitle
{
	return XPLocalizedString(@"SetMySQLRootPassword", 
							 @"Task description for the set mysql's root password task.");
}

- (BOOL) run
{
	MySQLPlugIn* plugIn;
	MySQLModule* module;
	NSBundle* bundle;
	NSError* error;
	BOOL shouldStop = NO;
	BOOL success = YES;
	
	bundle = [NSBundle bundleForClass:[self class]];
	
	plugIn = [[[[PlugInManager sharedPlugInManager] plugInInformations]
			   objectForKey:[bundle bundleIdentifier]]
			  objectForKey:@"instance"];
	module = [plugIn module];
	
	if ([module status] == XPNotRunning) {
		shouldStop = YES;
		error = [module start];
		if (error) {
			[XPAlert presentError:error];
			return NO;
		}
	}
	
	if (![self changePasswordInMySQL]) {
		if (shouldStop)
			[module stop];
		return NO;
	}
	
	if (![self updatePMAConfig]) {
		if (shouldStop)
			[module stop];
		return NO;
	}	
	
	if (shouldStop) {
		// TODO: Missing error check
		[module stop];
	}
	
	return success;
}

@end

@implementation MySQLRootPasswordTask(PRIVAT)

- (BOOL) changePasswordInMySQL
{
	MYSQL mysql;
	const char* sql;
	
	mysql_init(&mysql);
	
	if (!mysql_real_connect(&mysql, NULL, "root", "", 
							"mysql", 0, "/Applications/XAMPP/xamppfiles/var/mysql/mysql.sock", 0)) {
		
		NSLog(@"mysql: %s", mysql_error(&mysql));
		
		mysql_close(&mysql);
		return NO;
	}
	
	sql = [[NSString stringWithFormat:@"UPDATE user set Password=password('%@') where User = 'root';", [self password]] cString];
		
	if (mysql_real_query(&mysql, sql, strlen(sql))) {
		NSLog(@"mysql: %s", mysql_error(&mysql));
		
		mysql_close(&mysql);
		return NO;
	}
	
	mysql_close(&mysql);
	return YES;
}

- (BOOL) updatePMAConfig
{
	NSFileHandle* configFile;
	NSError* error;
	NSString* fileContents;
	NSMutableArray* lines;
	
	error = [XPRootTask authorize];
	if (error) {
		[XPAlert presentError:error];
		return NO;
	}
	
	configFile = [NSFileHandle fileHandleWithRootPrivilegesForUpdatingAtPath:[XPConfiguration fullXAMPPPathFor:@"/xamppfiles/phpmyadmin/config.inc.php"]];
	
	if(!configFile){
		NSLog(@"conf file nil");
		return NO;
	}
	NSData* data = [configFile readDataToEndOfFile];
	fileContents = [[NSString alloc] initWithData:data
										 encoding:NSUTF8StringEncoding];
	[configFile seekToEndOfFile];
	NSLog(@"seek %i", [configFile offsetInFile]);
	lines = [[fileContents componentsSeparatedByString:@"\n"] mutableCopy];
	[fileContents release];
	
	unsigned int  i, count = [lines count];
	for (i = 0; i < count; i++) {
		NSString* line = [lines objectAtIndex:i];
		
		if ([line hasPrefix:@"$cfg['Servers'][$i]['auth_type']"]) {
			line = [NSString stringWithFormat:@"# commented out by xampp security\n# %@\n$cfg['Servers'][$i]['auth_type'] = 'cookie';",
					line];
			[lines replaceObjectAtIndex:i
							 withObject:line];
		}
	}
	
	fileContents = [lines componentsJoinedByString:@"\n"];
	
	[configFile truncateFileAtOffset:0];
	[configFile writeData:[fileContents dataUsingEncoding:NSUTF8StringEncoding]];
	
	return YES;
}

@end
