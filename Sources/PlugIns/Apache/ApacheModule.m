//
//  ApacheModule.m
//  XAMPP Control
//
//  Created by Christian Speich on 23.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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
	XPRootTask *apachectl = [[XPRootTask alloc] init];
	NSString *output;
	NSError *error;
	
	working = YES;
	
	[self setStatus:XPStarting];
	
	// Fix Rights if needed
	[self checkFixRightsAndRunIfNeeded];
	
	[apachectl setLaunchPath:@"/Applications/XAMPP/xamppfiles/bin/apachectl"];
	if ([[NSFileManager defaultManager] 
		 fileExistsAtPath:@"/Applications/XAMPP/etc/xampp/startssl"
		 isDirectory:NO]) // Start with ssl
		[apachectl setArguments:[NSArray arrayWithObjects:@"-k", @"start", @"-DPHP5", @"-DSSL", nil]];
	else
		[apachectl setArguments:[NSArray arrayWithObjects:@"-k", @"start", @"-DPHP5", nil]];
	
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
	output = [[NSString alloc] initWithData:[[apachectl communicationsPipe] readDataToEndOfFile]
								   encoding:NSUTF8StringEncoding];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain 
								code:XPCantStart 
							userInfo:[NSDictionary dictionaryWithObject:output 
																 forKey:NSLocalizedDescriptionKey]];
	
	[apachectl release];
	[output release];
	
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
								code:XPCantStop 
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
