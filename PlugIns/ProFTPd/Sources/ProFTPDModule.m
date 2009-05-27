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

- (NSError*) start
{
	XPRootTask *proftpd = [[XPRootTask alloc] init];
	NSString *output;
	NSError *error;
	
	working = YES;
	
	[self setStatus:XPStarting];
	
	// Fix rights if needed
	[self checkFixRightsAndRunIfNeeded];
	
	[proftpd setLaunchPath:@"/Applications/XAMPP/xamppfiles/sbin/proftpd"];
	
	[proftpd setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	//[apachectl setStandardError:standardError];
	
	[proftpd launch];
	[proftpd waitUntilExit];
	
	if ([proftpd terminationStatus] == 0) { // Great proftpd is up and running :)
		[proftpd release];
		
		working = NO;
		return Nil;
	}
	
	// Hm, ok proftpd didn't start :/
	output = [[NSString alloc] initWithData:[[proftpd communicationsPipe] readDataToEndOfFile]
								   encoding:NSUTF8StringEncoding];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain 
								code:XPDidNotStart 
							userInfo:[NSDictionary dictionaryWithObject:output 
																 forKey:NSLocalizedDescriptionKey]];
	
	[output release];
	[proftpd release];
	
	[self setStatus:XPNotRunning];
	working = NO;
	return error;
}

- (NSError*) stop
{
	XPRootTask *kill = [[XPRootTask alloc] init];
	NSString *output;
	NSError *error;
	NSString *pid;
	
	working = YES;
	
	[self setStatus:XPStopping];
	
	pid = [[NSString stringWithContentsOfFile:pidFile] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
	
	[kill setLaunchPath:@"/bin/kill"];
	[kill setArguments:[NSArray arrayWithObjects:pid, nil]];
	
	//[apachectl setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	
	[kill launch];
	[kill waitUntilExit];
	
	if ([kill terminationStatus] == 0) { // Great proftpd is stopped :)
		[kill release];
		working = NO;
		return Nil;
	}
	
	// Hm, ok proftpd didn't stop?!?! :S
	output = [[NSString alloc] initWithData:[[kill communicationsPipe] readDataToEndOfFile]
								   encoding:NSUTF8StringEncoding];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain 
								code:XPDidNotStop 
							userInfo:[NSDictionary dictionaryWithObject:output 
																 forKey:NSLocalizedDescriptionKey]];
	
	[output release];
	[kill release];
	
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
