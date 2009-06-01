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

#import <XAMPP Control/XPError.h>
#import <XAMPP Control/XPRootTask.h>
#import <XAMPP Control/NSWorkspace (Process).h>
#import <unistd.h>

@interface ApacheModule(PRIVAT)

- (BOOL) systemApacheIsRunning;
- (NSError*) otherWebserverCheck;
- (NSError*) syntaxCheck;

- (NSArray*)defines;
- (BOOL) isSSLEnabled;

@end


@implementation ApacheModule

- (id) init
{
	self = [super init];
	if (self != nil) {		
		[self setPidFile:@"/Applications/XAMPP/xamppfiles/logs/httpd.pid"];
		[self setName:@"Apache"];
	}
	return self;
}

- (NSError*) realStart
{
	XPRootTask *apachectl = [[XPRootTask new] autorelease];
	NSMutableDictionary* errorDict;
	NSArray* arguments;
	NSError *error;
	
	if ([self systemApacheIsRunning]) {
		errorDict = [NSMutableDictionary dictionary];

		[errorDict setValue:@"Web Sharing is on!" 
					 forKey:NSLocalizedDescriptionKey];
		[errorDict setValue:@"XAMPP's Apache can not start until Web Sharing is turned off! Please go to the System Preferences and turn it in the sharing panel off." 
					 forKey:NSLocalizedRecoverySuggestionErrorKey];
		
		error = [NSError errorWithDomain:XAMPPControlErrorDomain
									code:XPWebSharingIsOn 
								userInfo:errorDict];
		
		return error;
	}
	
	error = [self otherWebserverCheck];
	if (error)
		return error;
	
	error = [self syntaxCheck];
	if (error)
		return error;
	
	error = [apachectl authorize];
	if (error)
		return error;
	
	// Fix Rights if needed
	[self checkFixRightsAndRunIfNeeded];
	
	[apachectl setLaunchPath:@"/Applications/XAMPP/xamppfiles/bin/apachectl"];
	arguments = [NSArray arrayWithObjects:@"-E", @"/Applications/XAMPP/xamppfiles/logs/error_log", @"-k", @"start", Nil];
	arguments = [arguments arrayByAddingObjectsFromArray:[self defines]];
	[apachectl setArguments:arguments];
	
	[apachectl setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	//[apachectl setStandardError:standardError];
	
	[apachectl launch];
	[apachectl waitUntilExit];
	
	if ([apachectl terminationStatus] == 0) { // Great apache is up and running :)
		return Nil;
	}
	
	// Hm, ok apache didn't start :/
	// Now let us create an error. Because the -E parameter of apachectl we're not intrested
	// in the output of the apachectl run. All important informations are located in the log
	// file. :)
	
	errorDict = [NSMutableDictionary dictionary];
	
	[errorDict setValue:@"/Applications/XAMPP/xamppfiles/logs/error_log"
				 forKey:XPErrorLogFileKey];
	[errorDict setValue:@"Apache did not start!" 
				 forKey:NSLocalizedDescriptionKey];
	[errorDict setValue:@"Please take a look into the log file of Apache for informations why Apache didn't start." 
				 forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain
								code:XPDidNotStart 
							userInfo:errorDict];

	return error;
}

- (NSError*) realStop
{
	XPRootTask *apachectl = [[XPRootTask new] autorelease];
	NSString *output;
	NSError *error;
	
	error = [apachectl authorize];
	if (error)
		return error;
	
	[apachectl setLaunchPath:@"/Applications/XAMPP/xamppfiles/bin/apachectl"];
	[apachectl setArguments:[NSArray arrayWithObjects:@"-k", @"stop", nil]];
	
	//[apachectl setEnvironment:[NSDictionary dictionaryWithObject:@"C" forKey:@"LANG"]];
	
	[apachectl launch];
	[apachectl waitUntilExit];
	
	if ([apachectl terminationStatus] == 0) { // Great apache is stopped :)
		return Nil;
	}
	
	// Hm, ok apache didn't stop?!?! :S
	output = [[[NSString alloc] initWithData:[[apachectl communicationsPipe] readDataToEndOfFile]
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
	
	error = [self syntaxCheck];
	if (error)
		return error;
	
	kill = [[XPRootTask new] autorelease];
	
	error = [kill authorize];
	if (error)
		return error;
	
	[kill setLaunchPath:@"/bin/kill"];
	[kill setArguments:[NSArray arrayWithObjects:@"-USR1", [NSString stringWithContentsOfFile:[self pidFile]], Nil]];
	
	// We don't check for success at all :)
	[kill launch];
	[kill waitUntilExit];
		
	return nil;
}

@end

@implementation ApacheModule(PRIVAT)

- (BOOL) systemApacheIsRunning
{
	NSString* pid;
	
	pid = [NSString stringWithContentsOfFile:@"/var/run/httpd.pid"];
	
	if (!pid)
		return NO;
	
	return [[NSWorkspace sharedWorkspace] processIsRunning:[pid intValue]];
}

- (NSError*) otherWebserverCheck
{
	NSError* error;
	NSMutableDictionary* errorDict;
	BOOL port80AlreadyUsed = NO;
	BOOL port443AlreadyUsed = NO;
	
	port80AlreadyUsed = [[NSWorkspace sharedWorkspace] portIsUsed:80];
	
	if ([self isSSLEnabled])
		port443AlreadyUsed = [[NSWorkspace sharedWorkspace] portIsUsed:443];
	
	if (!port80AlreadyUsed
		&& !port443AlreadyUsed)
		return Nil;
	
	errorDict = [NSMutableDictionary dictionary];
	
	[errorDict setValue:@"Another webserver is already running!" 
				 forKey:NSLocalizedDescriptionKey];
	
	if (port80AlreadyUsed && port443AlreadyUsed)
		[errorDict setValue:@"XAMPP's Apache can not start while another web server is using port 80 (and 433). Please turn it off and try again." 
					 forKey:NSLocalizedRecoverySuggestionErrorKey];
	else if (port443AlreadyUsed)
		[errorDict setValue:@"XAMPP's Apache can not start while another web server is using port 433. Please turn it off and try again." 
					 forKey:NSLocalizedRecoverySuggestionErrorKey];
	else
		[errorDict setValue:@"XAMPP's Apache can not start while another web server is using port 80. Please turn it off and try again." 
					 forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain
								code:XPOtherServerRunning 
							userInfo:errorDict];
	
	return error;
}

- (NSError*) syntaxCheck
{
	NSTask* httpd = [[NSTask new] autorelease];
	NSPipe* errorPipe = [NSPipe pipe];
	NSData* outputData;
	NSString* output;
	NSMutableDictionary* errDict;
	
	[httpd setLaunchPath:@"/Applications/XAMPP/xamppfiles/bin/httpd"];
	[httpd setArguments:[[self defines] arrayByAddingObject:@"-t"]];
	[httpd setStandardError:errorPipe];
	
	[httpd launch];
	[httpd waitUntilExit];
	
	if ([httpd terminationStatus] == 0)
		return Nil;
	
	outputData = [[errorPipe fileHandleForReading] readDataToEndOfFile];
	output = [[[NSString alloc] initWithData:outputData encoding:NSASCIIStringEncoding] autorelease];
	
	output = [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	errDict = [NSMutableDictionary dictionary];
	
	[errDict setValue:@"Apache syntax error!" 
			   forKey:NSLocalizedDescriptionKey];
	[errDict setValue:output
			   forKey:NSLocalizedRecoverySuggestionErrorKey];
	
	return [NSError errorWithDomain:XAMPPControlErrorDomain 
							   code:XPSyntaxError 
						   userInfo:errDict];
}

- (NSArray*)defines
{
	NSMutableArray* defines = [NSMutableArray array];
	
	[defines addObject: @"-DPHP5"];
	
	if ([self isSSLEnabled]) {
		[defines addObject:@"-DSSL"];
	}
	
	return defines;
}

- (BOOL) isSSLEnabled
{
	return [[NSFileManager defaultManager] 
			fileExistsAtPath:@"/Applications/XAMPP/etc/xampp/startssl"];
}

@end
