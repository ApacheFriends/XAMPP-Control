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

#import "ApacheModule.h"

#import <SharedXAMPPSupport/XPError.h>
#import <SharedXAMPPSupport/XPRootTask.h>
#import <unistd.h>

@implementation ApacheModule

- (id) init
{
	self = [super init];
	if (self != nil) {		
		[self setPidFile:@"/Applications/XAMPP/xamppfiles/logs/httpd.pid"];
	}
	return self;
}

- (NSString*) name
{
	return @"Apache";
}

- (NSError*) start
{
	XPRootTask *apachectl = [XPRootTask new];
	NSMutableDictionary* errorDict;
	NSError *error;
	
	working = YES;
	
	[self setStatus:XPStarting];
	
	error = [apachectl authorize];
	if (error) {
		[apachectl release];
		working = NO;
		
		[self setStatus:XPNotRunning];
		
		return error;
	}
	
	// Fix Rights if needed
	[self checkFixRightsAndRunIfNeeded];
	
	[apachectl setLaunchPath:@"/Applications/XAMPP/xamppfiles/bin/apachectl"];
	if ([[NSFileManager defaultManager] 
		 fileExistsAtPath:@"/Applications/XAMPP/etc/xampp/startssl"
		 isDirectory:NO]) // Start with ssl
		[apachectl setArguments:[NSArray arrayWithObjects:@"-E", @"/Applications/XAMPP/xamppfiles/logs/error_log", @"-k", @"start", @"-DPHP5", @"-DSSL", nil]];
	else
		[apachectl setArguments:[NSArray arrayWithObjects:@"-E", @"/Applications/XAMPP/xamppfiles/logs/error_log", @"-k", @"start", @"-DPHP5", nil]];
	
	[apachectl setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	//[apachectl setStandardError:standardError];
	
	[apachectl launch];
	[apachectl waitUntilExit];
	
	if ([apachectl terminationStatus] == 0) { // Great apache is up and running :)
		[apachectl release];
		
		// Ok, wait until a pid file is created, to prevent the status check to dedect a not running apache
		// while he is in the starting phase ;) Not nice but works
		while (![[NSFileManager defaultManager] fileExistsAtPath:pidFile isDirectory:NO]) usleep(5000);
		
		working = NO;
		return Nil;
	}
	
	// Hm, ok apache didn't start :/
	// Now let us create an error. Because the -E parameter of apachectl we're not intrested
	// in the output of the apachectl run. All important informations are located in the log
	// file. :)
	
	errorDict = [NSMutableDictionary new];
	
	[errorDict setValue:@"/Applications/XAMPP/xamppfiles/logs/error_log"
				 forKey:XPErrorLogFileKey];
	[errorDict setValue:[self name] 
				 forKey:XPErrorModuleNameKey];
	[errorDict setValue:@"Apache did not start!" 
				 forKey:NSLocalizedDescriptionKey];
	[errorDict setValue:@"Please take a look into the log file of Apache for informations why Apache didn't start." 
				 forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain
								code:XPDidNotStart 
							userInfo:errorDict];
	
	[errorDict release];
	[apachectl release];
	
	[self setStatus:XPNotRunning];
	working = NO;
	return error;
}

- (NSError*) stop
{
	XPRootTask *apachectl = [[XPRootTask alloc] init];
	NSString *output;
	NSError *error;
	
	working = YES;
	
	[self setStatus:XPStopping];
	
	[apachectl setLaunchPath:@"/Applications/XAMPP/xamppfiles/bin/apachectl"];
	[apachectl setArguments:[NSArray arrayWithObjects:@"-k", @"stop", nil]];
	
	//[apachectl setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	
	[apachectl launch];
	[apachectl waitUntilExit];
	
	if ([apachectl terminationStatus] == 0) { // Great apache is stopped :)
		[apachectl release];
		working = NO;
		return Nil;
	}
	
	// Hm, ok apache didn't stop?!?! :S
	output = [[NSString alloc] initWithData:[[apachectl communicationsPipe] readDataToEndOfFile]
								   encoding:NSUTF8StringEncoding];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain 
								code:XPDidNotStop 
							userInfo:[NSDictionary dictionaryWithObject:output 
																 forKey:NSLocalizedDescriptionKey]];
	
	[output release];
	[apachectl release];
	
	[self setStatus:XPRunning];
	working = NO;
	return error;
}

- (NSError*) reload
{
	XPRootTask *kill;
	
	kill = [[XPRootTask alloc] init];
	
	[kill setLaunchPath:@"/bin/kill"];
	[kill setArguments:[NSArray arrayWithObjects:@"-USR1", [NSString stringWithContentsOfFile:[self pidFile]], Nil]];
	
	// We don't check for success at all :)
	[kill launch];
	[kill waitUntilExit];
	
	[kill release];
	
	return nil;
}

@end
