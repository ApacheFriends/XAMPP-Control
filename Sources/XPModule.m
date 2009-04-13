//
//  XPModule.m
//  XAMPP Control
//
//  Created by Christian Speich on 03.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XPModule.h"
#import "NSWorkspace (Process).h"
#import "KQueue.h"
#import "XPRootTask.h"
#import "XPConfiguration.h"
#include <unistd.h>

static NSLock *fixRightsLock = Nil;

@implementation XPModule

- (id) init
{
	self = [super init];
	if (self != nil) {
		pidFile = Nil;
		status = XPUnknownStatus;
		working = NO;
		
		if (fixRightsLock == Nil)
			fixRightsLock = [[NSLock alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newKEvent:)
													 name:KQueueNewEvent
												   object:[KQueue sharedKQueue]];
	}
	return self;
}

- (void) dealloc
{
	[checkTimer invalidate];
	[checkTimer release];
	
	[super dealloc];
}

- (NSString*) name
{
	[[NSException exceptionWithName:@"NotImplemented" 
							 reason:@"NotImplemented" 
						   userInfo:nil] raise];
	return nil;
}

- (NSError*) start
{
	[[NSException exceptionWithName:@"NotImplemented" 
							 reason:@"NotImplemented" 
						   userInfo:nil] raise];
	return nil;
}

- (NSError*) stop
{
	[[NSException exceptionWithName:@"NotImplemented" 
							 reason:@"NotImplemented" 
						   userInfo:nil] raise];
	return nil;
}

- (NSError*) reload
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

		[self refreshStatusCheck];
		[self didChangeValueForKey:@"status"];
	}
}

- (NSString*) pidFile
{
	return pidFile;
}

- (void) setPidFile:(NSString*) aPidFile
{
	if ([aPidFile isEqualToString:pidFile])
		return;
	
	[self removeStatusCheck];
	[pidFile release];
	pidFile = [aPidFile retain];
	[self setupStatusCheck];
}

#pragma mark -
#pragma mark Privat Methods

- (void) removeStatusCheck
{
	if (watchDirFD > 0) {
		[[KQueue sharedKQueue] removeIdent:watchDirFD fromFilter:KQueueVNodeFilter];
		close(watchDirFD);
		watchDirFD = -1;
	}
	if (watchPID > 0) {
		[[KQueue sharedKQueue] removeIdent:watchPID fromFilter:KQueueProcFilter];
		watchPID = -1;
	}
}

- (void) setupStatusCheck
{
	watchDirFD = -1;
	watchPID = -1;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:pidFile isDirectory:NO]) {
		// It's probbably running, but check it :)
		
		pid_t pid = [[NSString stringWithContentsOfFile:pidFile] intValue];
		
		if (pid < 0 
			|| ![[NSWorkspace sharedWorkspace] processIsRunning:pid]) {
			[self setStatus:XPNotRunning];
		}
		else {
			[self setStatus:XPRunning];
		}

	}
	else {
		[self setStatus:XPNotRunning];
	}
	[self refreshStatusCheck];
}

- (void) refreshStatusCheck
{
	pid_t pid = [[NSString stringWithContentsOfFile:pidFile] intValue];
	
	if (watchPID < 0 && status == XPRunning && pid > 0) {
		// The Module is running but we dont watch the pid for exit
		
		if (watchDirFD > 0) {
			[[KQueue sharedKQueue] removeIdent:watchDirFD
									fromFilter:KQueueVNodeFilter];
			close(watchDirFD);
			watchDirFD = -1;
		}
				
		// Set up watch
		[[KQueue sharedKQueue] addIdent:pid 
							 withFilter:KQueueProcFilter 
						 andFilterFlags:KQueueProcessExitFilterFlag];
		watchPID = pid;
	}
	else if (watchDirFD < 0 && status == XPNotRunning) {
		// the Module is not running but we dont watch the dir for a new pid file
		
		if (watchPID > 0) {
			[[KQueue sharedKQueue] removeIdent:watchPID 
									fromFilter:KQueueProcFilter];
			watchPID = -1;
		}
				
		// Set up watch
		watchDirFD = open([[pidFile stringByDeletingLastPathComponent] fileSystemRepresentation], O_EVTONLY, 0);

		if (watchDirFD < 0)
			NSLog(@"Directory for pid does not exits!");
		else 
			[[KQueue sharedKQueue] addIdent:watchDirFD 
								 withFilter:KQueueVNodeFilter 
							 andFilterFlags:KQueueVNodeWriteFilterFlag];
	}
}

- (void) newKEvent:(NSNotification*)noti
{
	//NSLog(@"Notifaction %@", noti);
	NSDictionary *userInfo = [noti userInfo];
	
	if ([[userInfo valueForKey:KQueueFilterKey] isEqualToString:KQueueVNodeFilter]
		&& [[userInfo valueForKey:KQueueIdentKey] isEqualToNumber:[NSNumber numberWithInt:watchDirFD]]
		&& [[userInfo valueForKey:KQueueFilterFlagsKey] intValue] & KQueueVNodeWriteFilterFlag
		&& [[NSFileManager defaultManager] fileExistsAtPath:pidFile isDirectory:NO]) {
		
		pid_t pid = [[NSString stringWithContentsOfFile:pidFile] intValue];
		
		if ([[NSWorkspace sharedWorkspace] processIsRunning:pid])
			[self setStatus:XPRunning];
	}
	else if ([[userInfo valueForKey:KQueueFilterKey] isEqualToString:KQueueProcFilter]
			 && [[userInfo valueForKey:KQueueIdentKey] isEqualToNumber:[NSNumber numberWithInt:watchPID]]
			 && [[userInfo valueForKey:KQueueFilterFlagsKey] intValue] & KQueueProcessExitFilterFlag)
		[self setStatus:XPNotRunning];
		
		
}

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
