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

#import "ProFTPDModule.h"

#import <XAMPP Control/XPError.h>
#import <XAMPP Control/XPRootTask.h>
#import <XAMPP Control/XPConfiguration.h>
#import <XAMPP Control/NSWorkspace+Additions.h>
#import <unistd.h>

@interface ProFTPDModule (PRIVAT)

- (NSError*) otherFTPServerCheck;

@end


@implementation ProFTPDModule

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self setPidFile:[XPConfiguration fullXAMPPPathFor:@"/xamppfiles/var/proftpd.pid"]];
		[self setName:@"FTP"];
	}
	return self;
}

- (NSError*) realStart
{
	XPRootTask *proftpd = [[XPRootTask new] autorelease];
	NSString *output;
	NSError *error;
	
	error = [proftpd authorize];
	if (error)
		return error;
	
	// Fix rights if needed
	[self checkFixRightsAndRunIfNeeded];
	
	[proftpd setLaunchPath:[XPConfiguration fullXAMPPPathFor:@"/xamppfiles/sbin/proftpd"]];
	
	[proftpd setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	//[apachectl setStandardError:standardError];
	
	[proftpd launch];
	[proftpd waitUntilExit];
	
	if ([proftpd terminationStatus] == 0) // Great proftpd is up and running :)
		return Nil;
	
	// Hm, ok proftpd didn't start :/
	output = [[[NSString alloc] initWithData:[[proftpd communicationsPipe] readDataToEndOfFile]
								    encoding:NSUTF8StringEncoding] autorelease];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain 
								code:XPDidNotStart 
							userInfo:[NSDictionary dictionaryWithObject:output 
																 forKey:NSLocalizedDescriptionKey]];
	
	return error;
}

- (NSError*) runStartTests
{
	NSError* error;
	
	error = [super runStartTests];
	if (error)
		return error;
	
	error = [self otherFTPServerCheck];
	if (error)
		return error;
	
	return Nil;
}

- (NSError*) realStop
{
	XPRootTask *kill = [[XPRootTask new] autorelease];
	NSString *output;
	NSError *error;
	NSString *pid;
	
	error = [kill authorize];
	if (error)
		return error;
	
	pid = [[NSString stringWithContentsOfFile:pidFile] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
	
	[kill setLaunchPath:@"/bin/kill"];
	[kill setArguments:[NSArray arrayWithObjects:pid, nil]];
	
	//[apachectl setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	
	[kill launch];
	[kill waitUntilExit];
	
	if ([kill terminationStatus] == 0) // Great proftpd is stopped :)
		return Nil;

	// Hm, ok proftpd didn't stop?!?! :S
	output = [[[NSString alloc] initWithData:[[kill communicationsPipe] readDataToEndOfFile]
									encoding:NSUTF8StringEncoding] autorelease];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain 
								code:XPDidNotStop 
							userInfo:[NSDictionary dictionaryWithObject:output 
																 forKey:NSLocalizedDescriptionKey]];

	return error;
}

- (NSError*) realReload
{
	XPRootTask *kill;
	NSError* error;
	
	kill = [[XPRootTask new] autorelease];
	
	error = [kill authorize];
	if (error)
		return error;
	
	[kill setLaunchPath:@"/bin/kill"];
	[kill setArguments:[NSArray arrayWithObjects:@"-HUP", [NSString stringWithContentsOfFile:[self pidFile]], Nil]];
	
	// We don't check for success at all :)
	[kill launch];
	[kill waitUntilExit];
		
	return nil;
}

#pragma mark -
#pragma mark Priority Protocol

- (int) priority
{
	return -1000;
}

- (NSString*) comparisonString
{
	return @"ProFTPD";
}

@end

@implementation ProFTPDModule (PRIVAT)

- (NSError*) otherFTPServerCheck
{
	NSError* error;
	NSMutableDictionary* errorDict;
	
	if (![[NSWorkspace sharedWorkspace] isPortInUse:21])
		return Nil;
	
	errorDict = [NSMutableDictionary dictionary];
	
	[errorDict setValue:XPLocalizedString(@"AnotherFTPserverError", @"Another ftpserver is already running!")
				 forKey:NSLocalizedDescriptionKey];
	[errorDict setValue:XPLocalizedString(@"AnotherFTPserverErrorDescription", @"XAMPP's FTP can not start while another ftpserver is using port 21. Please turn it off and try again.")
				 forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain
								code:XPOtherServerRunning 
							userInfo:errorDict];
	
	return error;
}

@end
