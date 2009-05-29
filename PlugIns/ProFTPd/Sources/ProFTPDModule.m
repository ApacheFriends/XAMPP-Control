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

#import "ProFTPDModule.h"

#import <SharedXAMPPSupport/XPError.h>
#import <SharedXAMPPSupport/XPRootTask.h>
#import <unistd.h>

@implementation ProFTPDModule

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self setPidFile:@"/Applications/XAMPP/xamppfiles/var/proftpd.pid"];
	}
	return self;
}

- (NSString*) name
{
	return @"FTP";
}

- (NSError*) doStart
{
	XPRootTask *proftpd = [[XPRootTask new] autorelease];
	NSString *output;
	NSError *error;
	
	error = [proftpd authorize];
	if (error)
		return error;
	
	// Fix rights if needed
	[self checkFixRightsAndRunIfNeeded];
	
	[proftpd setLaunchPath:@"/Applications/XAMPP/xamppfiles/sbin/proftpd"];
	
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

- (NSError*) doStop
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

- (NSError*) doReload
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

@end
