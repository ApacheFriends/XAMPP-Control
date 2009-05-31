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

#import "XPModule.h"
#import "NSWorkspace (Process).h"
#import "KQueue.h"
#import "XPRootTask.h"
#import "XPConfiguration.h"
#import "XPProcessWatcher.h"
#include <unistd.h>

static NSLock *fixRightsLock = Nil;

@interface XPModule(PRIVAT)

- (NSError*) realStart;
- (NSError*) realStop;
- (NSError*) realReload;

@end


@implementation XPModule

- (id) init
{
	self = [super init];
	if (self != nil) {
		apacheWatcher = [XPProcessWatcher new];
		pidFile = Nil;
		status = XPUnknownStatus;
		
		[apacheWatcher setDelegate:self];
		
		if (fixRightsLock == Nil)
			fixRightsLock = [[NSLock alloc] init];

	}
	return self;
}

- (void) dealloc
{
	[apacheWatcher release];
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

- (NSError*) start
{
	NSAutoreleasePool* pool;
	NSError* error = Nil;
	
	if ([self status] == XPRunning)
		return Nil;
	
	pool  = [NSAutoreleasePool new];
	
	[self setStatus:XPStarting];
	
	error = [[self realStart] retain];
	
	if (error)
		[self setStatus:XPNotRunning];
	else
		[self setStatus:XPRunning];
	
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

- (NSError*) stop
{
	NSAutoreleasePool* pool;
	NSError* error = Nil;
	
	if ([self status] == XPNotRunning)
		return Nil;
	
	pool  = [NSAutoreleasePool new];
	
	[self setStatus:XPStopping];
	
	error = [[self realStop] retain];
	
	if (error)
		[self setStatus:XPRunning];
	else
		[self setStatus:XPNotRunning];
	
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
	
	if ([self status] != XPRunning)
// TODO: Make an NSError for this situation
		return Nil;
	
	pool = [NSAutoreleasePool new];
	
	[self setStatus:XPStopping];
	
	error = [[self realReload] retain];
	
	[self setStatus:XPRunning];
	
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
	if (![NSThread isMainThread])
		NSLog(@"[%@ setStatus:%i] not on the main thread", self, aStatus);
	
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
	[apacheWatcher setPidFile:aPidFile];
	
	if ([aPidFile isEqualToString:pidFile])
		return;
	
	//[self removeStatusCheck];
	[pidFile release];
	pidFile = [aPidFile retain];
	//[self setupStatusCheck];
}

- (void) processExited:(XPProcessWatcher*)watcher
{
	if ([watcher isEqualTo:apacheWatcher]) {
		[self setStatus:XPNotRunning];
	}
}

- (void) processStarted:(XPProcessWatcher*)watcher
{
	if ([watcher isEqualTo:apacheWatcher]) {
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
		
		[fix_rights setLaunchPath:@"/Applications/XAMPP/xamppfiles/bin/fix_rights"];
		
		[fix_rights launch];
		[fix_rights waitUntilExit];
		
		[fix_rights release];
	}
	
	[fixRightsLock unlock];
}

@end
