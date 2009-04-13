//
//  XPMySQL.m
//  XAMPP Control
//
//  Created by Christian Speich on 04.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XPMySQL.h"
#import "XPRootTask.h"
#import "XPError.h"
#include <unistd.h>

@implementation XPMySQL

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
	NSString *output;
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
	output = [[NSString alloc] initWithData:[[mysqlServer communicationsPipe] readDataToEndOfFile]
								   encoding:NSUTF8StringEncoding];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain 
								code:XPCantStart 
							userInfo:[NSDictionary dictionaryWithObject:output 
																 forKey:NSLocalizedDescriptionKey]];
	
	[output release];
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
								code:XPCantStop 
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
	[kill setArguments:[NSArray arrayWithObjects:@"-HUP", [NSString stringWithContentsOfFile:[self pidFile]]]];
	
	// We don't check for success at all :)
	[kill launch];
	[kill waitUntilExit];
	
	[kill release];
	
	return nil;
}

@end
