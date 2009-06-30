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

#import "XPModule.h"
#import "NSWorkspace (Process).h"
#import "NSObject (MainThread).h"
#import "KQueue.h"
#import "XPRootTask.h"
#import "XPConfiguration.h"
#import "XPProcessWatcher.h"
#import "XPError.h"
#import "XPHostnameResolveRecoveryAttempter.h"
#include <unistd.h>
#include <netdb.h>

static NSLock *fixRightsLock = Nil;

@interface XPModule(PRIVAT)

- (NSError*) realStart;
- (NSError*) runStartTests;
- (NSError*) realStop;
- (NSError*) realReload;

- (NSError*) hostnameCheck;

@end


@implementation XPModule

- (id) init
{
	self = [super init];
	if (self != nil) {
		processWatcher = [XPProcessWatcher new];
		pidFile = Nil;
		status = XPUnknownStatus;
		
		[self setShouldRunStartTests:YES];
		
		[processWatcher setDelegate:self];
		
		if (fixRightsLock == Nil)
			fixRightsLock = [[NSLock alloc] init];

	}
	return self;
}

- (void) dealloc
{
	[processWatcher release];
	[self setName:Nil];
	[self setPidFile:Nil];
	
	[super dealloc];
}

- (NSString*) name
{
	return _name;
}

- (void) setName:(NSString*)anName
{
	if ([anName isEqualToString:_name])
		return;
	
	[self willChangeValueForKey:@"name"];
	
	[_name release];
	_name = [anName retain];
	
	[self didChangeValueForKey:@"name"];
}

- (BOOL) shouldRunStartTests
{
	return _shouldRunStartTests;
}

- (void) setShouldRunStartTests:(BOOL)should
{
	if (should == _shouldRunStartTests)
		return;
	
	[self willChangeValueForKey:@"shouldRunStartTests"];
	_shouldRunStartTests = should;
	[self didChangeValueForKey:@"shouldRunStartTests"];
}

- (NSError*) start
{
	NSAutoreleasePool* pool;
	NSError* error = Nil;
	id mainThreadInstance;

	if ([self status] == XPRunning)
		return Nil;
	
	pool  = [NSAutoreleasePool new];
	mainThreadInstance = [self mainThreadProxy];
	
	[mainThreadInstance setStatus:XPStarting];
	
	if ([self shouldRunStartTests])
		error = [[self runStartTests] retain];
	
	if (!error)
		error = [[self realStart] retain];
	
	if (error)
		[mainThreadInstance setStatus:XPNotRunning];
	else
		[mainThreadInstance setStatus:XPRunning];
	
	[pool release];
	return [error autorelease];
}

- (NSError*) realStart
{
	[[NSException exceptionWithName:@"NotImplemented" 
							 reason:@"NotImplemented" 
						   userInfo:nil] raise];
	return nil;
}

- (NSError*) runStartTests
{
	NSError* error = Nil;
	
	error = [self hostnameCheck];
	
	return error;
}

- (NSError*) stop
{
	NSAutoreleasePool* pool;
	NSError* error = Nil;
	id mainThreadInstance;
	
	if ([self status] == XPNotRunning)
		return Nil;
	
	pool  = [NSAutoreleasePool new];
	mainThreadInstance = [self mainThreadProxy];
	
	[mainThreadInstance setStatus:XPStopping];
	
	error = [[self realStop] retain];

	if (error)
		[mainThreadInstance setStatus:XPRunning];
	else
		[mainThreadInstance setStatus:XPNotRunning];
	
	[pool release];
	return [error autorelease];
}

- (NSError*) realStop
{
	[[NSException exceptionWithName:@"NotImplemented" 
							 reason:@"NotImplemented" 
						   userInfo:nil] raise];
	return nil;
}

- (NSError*) reload
{
	NSAutoreleasePool* pool;
	NSError* error = Nil;
	id mainThreadInstance;
	
	if ([self status] != XPRunning)
// TODO: Make an NSError for this situation
		return Nil;
	
	pool = [NSAutoreleasePool new];
	mainThreadInstance = [self mainThreadProxy];
	
	[mainThreadInstance setStatus:XPStopping];
	
	error = [[self realReload] retain];
	
	[mainThreadInstance setStatus:XPRunning];
	
	[pool release];
	return [error autorelease];
}

- (NSError*) realReload
{
	[[NSException exceptionWithName:@"NotImplemented" 
							 reason:@"NotImplemented" 
						   userInfo:nil] raise];
	return nil;
}

- (XPStatus) status
{
	return status;
}

- (void) setStatus:(XPStatus) aStatus
{
	if (status != aStatus) {
		[self willChangeValueForKey:@"status"];
		status = aStatus;

		//[self refreshStatusCheck];
		[self didChangeValueForKey:@"status"];
	}
}

- (NSString*) pidFile
{
	return pidFile;
}

- (void) setPidFile:(NSString*) aPidFile
{
	[processWatcher setPidFile:aPidFile];
	
	if ([aPidFile isEqualToString:pidFile])
		return;
	
	[pidFile release];
	pidFile = [aPidFile retain];
}

- (void) processExited:(XPProcessWatcher*)watcher
{
	if ([watcher isEqualTo:processWatcher]) {
		[self setStatus:XPNotRunning];
	}
}

- (void) processStarted:(XPProcessWatcher*)watcher
{
	if ([watcher isEqualTo:processWatcher]) {
		[self setStatus:XPRunning];
	}
}

#pragma mark -
#pragma mark Privat Methods

- (void) checkFixRightsAndRunIfNeeded
{
	NSAssert(fixRightsLock != Nil, @"fixRighsLock must be not Nil");
	
	// Be sure to not run 2 or more fix_rights at one time
	[fixRightsLock lock];
	
	// If rights has allready fixed, skip it
	if (![[XPConfiguration sharedConfiguration] hasFixRights]) {
		XPRootTask *fix_rights = [[XPRootTask alloc] init];
		
		[fix_rights setLaunchPath:[XPConfiguration fullXAMPPPathFor:@"/xamppfiles/bin/fix_rights"]];
		
		[fix_rights launch];
		[fix_rights waitUntilExit];
		
		[fix_rights release];
	}
	
	[fixRightsLock unlock];
}

- (NSError*) hostnameCheck
{
	NSError* error;
	NSMutableDictionary* errorDict;
	char hostname[256];
	struct hostent *ent;
	
	gethostname(hostname, 256);
	ent = gethostbyname(hostname);
	
	if (ent != NULL) // Everything is fine :)
		return Nil;
	
	
	errorDict = [NSMutableDictionary dictionary];
	
	[errorDict setValue:@"The hostname can not resolved!" 
				 forKey:NSLocalizedDescriptionKey];
	[errorDict setValue:@"XAMPP can not resolve the IP for the hostname of this computer. By clicking 'OK', XAMPP will add the hostname to the hosts-File." 
				 forKey:NSLocalizedRecoverySuggestionErrorKey];
	[errorDict setValue:[NSArray arrayWithObjects:@"OK",@"Cancel",Nil]
				 forKey:NSLocalizedRecoveryOptionsErrorKey];
	[errorDict setValue:[[[XPHostnameResolveRecoveryAttempter alloc] initWithModule:self] autorelease]
				 forKey:NSRecoveryAttempterErrorKey];
	
	error = [NSError errorWithDomain:XAMPPControlErrorDomain
								code:XPHostnameResolveFail 
							userInfo:errorDict];
		
	return error;
}

@end
