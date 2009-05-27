/*
 
 XAMPP
 Copyright (C) 2009 by Apache Friends
 
 Authors of this file:
 - Christian Speich <kleinweby@apachefriends>
 
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

#import "MySQLModule.h"

#import <SharedXAMPPSupport/XPError.h>
#import <SharedXAMPPSupport/XPRootTask.h>
#import <unistd.h>

@implementation MySQLModule

- (id) init
{
	self = [super init];
	if (self != nil) {
		char hostname[256];
		
		gethostname(hostname, 256);
		
		[self setPidFile:[NSString stringWithFormat:@"/Applications/XAMPP/xamppfiles/var/mysql/%s.pid", hostname]];
	}
	return self;
}

- (NSString*) name
{
	return @"MySQL";
}

- (NSError*) start
{
	XPRootTask *mysqlServer = [[XPRootTask alloc] init];
	NSMutableDictionary* errorDict;
	NSError *error;
	
	working = YES;
	
	[self setStatus:XPStarting];
	
	// Fix rights if needed
	[self checkFixRightsAndRunIfNeeded];
	
	[mysqlServer setLaunchPath:@"/Applications/XAMPP/xamppfiles/bin/mysql.server"];
	[mysqlServer setArguments:[NSArray arrayWithObjects:@"start", nil]];
	
	[mysqlServer setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	//[mysqlServer setStandardError:standardError];
	
	[mysqlServer launch];
	[mysqlServer waitUntilExit];
	
	if ([mysqlServer terminationStatus] == 0) { // Great mysql is up and running :)
		[mysqlServer release];
		
		working = NO;
		return Nil;
	}
	
	// Hm, ok mysql didn't start :/
	errorDict = [NSMutableDictionary new];
	
	[errorDict setValue:@"/Applications/XAMPP/xamppfiles/logs/error_log"
				 forKey:XPErrorLogFileKey];
	[errorDict setValue:[self name] 
				 forKey:XPErrorModuleNameKey];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain
								code:XPDidNotStart 
							userInfo:errorDict];
	
	[errorDict release];
	[mysqlServer release];
	
	[self setStatus:XPNotRunning];
	working = NO;
	return error;
}

- (NSError*) stop
{
	XPRootTask *mysqlServer = [[XPRootTask alloc] init];
	NSString *output;
	NSError *error;
	
	working = YES;
	
	[self setStatus:XPStopping];
	
	[mysqlServer setLaunchPath:@"/Applications/XAMPP/xamppfiles/bin/mysql.server"];
	[mysqlServer setArguments:[NSArray arrayWithObjects:@"stop", nil]];
	
	[mysqlServer setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	//[mysqlServer setStandardError:standardError];
	
	[mysqlServer launch];
	[mysqlServer waitUntilExit];
	
	if ([mysqlServer terminationStatus] == 0) { // Great mysql has stopped :)
		[mysqlServer release];
		working = NO;
		return Nil;
	}
	
	// Hm, ok mysql didn't stop?!?! :/
	output = [[NSString alloc] initWithData:[[mysqlServer communicationsPipe] readDataToEndOfFile]
								   encoding:NSUTF8StringEncoding];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain 
								code:XPDidNotStop 
							userInfo:[NSDictionary dictionaryWithObject:output 
																 forKey:NSLocalizedDescriptionKey]];
	
	[mysqlServer release];
	[output release];
	
	[self setStatus:XPRunning];
	working = NO;
	return error;
}

- (NSError*) reload
{
	XPRootTask *kill;
	
	kill = [[XPRootTask alloc] init];
	
	[kill setLaunchPath:@"/bin/kill"];
	[kill setArguments:[NSArray arrayWithObjects:@"-HUP", [NSString stringWithContentsOfFile:[self pidFile]], Nil]];
	
	// We don't check for success at all :)
	[kill launch];
	[kill waitUntilExit];
	
	[kill release];
	
	return nil;
}

@end
