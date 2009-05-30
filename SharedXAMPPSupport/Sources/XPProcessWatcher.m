//
//  XPProcessWatcher.m
//  XAMPP Control
//
//  Created by Christian Speich on 30.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XPProcessWatcher.h"
#import "KQueue.h"
#import "NSWorkspace (Process).h"

#include <unistd.h>

enum {
	ProcessNotRunning,
	ProcessRunning,
	ProcessUnknown
};

@interface XPProcessWatcher (PRIVAT)

- (void) setStatus:(int)status;
- (void) removeFromKQueue;
- (void) setupWatchForPIDFile;
- (void) setupWatchForPID;

@end


@implementation XPProcessWatcher

- (id) init
{
	self = [super init];
	if (self != nil) {
		status = ProcessUnknown;
		
		watchPID = -1;
		watchDirFD = -1;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(newKEvent:)
													 name:KQueueNewEvent
												   object:[KQueue sharedKQueue]];
	}
	return self;
}

- (void) dealloc
{
	[self removeFromKQueue];
	[self setPidFile:Nil];
	[self setDelegate:Nil];
	
	[super dealloc];
}


- (NSString*) pidFile
{
	return pidFile;
}

- (void) setPidFile:(NSString*)anPidFile
{
	if ([anPidFile isEqualToString:pidFile])
		return;
	
	[self removeFromKQueue];
	
	[pidFile release];
	pidFile = [anPidFile retain];
	
	[self forceCheckNow];
}

- (id) delegate
{
	return delegate;
}

- (void) setDelegate:(id)anDelegate
{
	delegate = anDelegate;
}

- (void) forceCheckNow
{
	NSString* pidFileContent = [NSString stringWithContentsOfFile:[self pidFile]];
	pid_t pid = [pidFileContent intValue];

	[self setStatus:ProcessUnknown];
	
	if (!pidFileContent || pid < 0
		|| ![[NSWorkspace sharedWorkspace] processIsRunning:pid]) {
		[self setStatus:ProcessNotRunning];
		[self setupWatchForPIDFile];
	}
	else {
		[self setStatus:ProcessRunning];
		[self setupWatchForPID];
	}
}

- (void) newKEvent:(NSNotification*)noti
{
	NSDictionary *userInfo = [noti userInfo];

	if ([[userInfo valueForKey:KQueueFilterKey] isEqualToString:KQueueVNodeFilter]
		&& [[userInfo valueForKey:KQueueIdentKey] isEqualToNumber:[NSNumber numberWithInt:watchDirFD]]
		&& [[userInfo valueForKey:KQueueFilterFlagsKey] intValue] & KQueueVNodeWriteFilterFlag
		&& [[NSFileManager defaultManager] fileExistsAtPath:pidFile isDirectory:NO]) {
		
		pid_t pid = [[NSString stringWithContentsOfFile:pidFile] intValue];
		
		if ([[NSWorkspace sharedWorkspace] processIsRunning:pid]) {
			[self removeFromKQueue];
			[self setStatus:ProcessRunning];
			[self setupWatchForPID];
		}
		else {
			NSLog(@"PID File %@ created but process is not running");
		}

	}
	else if ([[userInfo valueForKey:KQueueFilterKey] isEqualToString:KQueueProcFilter]
			 && [[userInfo valueForKey:KQueueIdentKey] isEqualToNumber:[NSNumber numberWithInt:watchPID]]
			 && [[userInfo valueForKey:KQueueFilterFlagsKey] intValue] & KQueueProcessExitFilterFlag) {
		[self removeFromKQueue];
		[self setStatus:ProcessNotRunning];
		[self setupWatchForPIDFile];
	}	
}

@end

@implementation XPProcessWatcher (PRIVAT)

- (void) setStatus:(int)anStatus
{
	if (anStatus == status)
		return;
	
	status = anStatus;
		
	switch (status) {
		case ProcessNotRunning:
			[delegate performSelector:@selector(processExited:) withObject:self];
			break;
		case ProcessRunning:
			[delegate performSelector:@selector(processStarted:) withObject:self];
			break;
	}
}

- (void) removeFromKQueue
{
	if (watchPID >= 0) {
		[[KQueue sharedKQueue] removeIdent:watchPID 
								fromFilter:KQueueProcFilter];
		watchPID = -1;
	}
	
	if (watchDirFD >= 0) {
		[[KQueue sharedKQueue] removeIdent:watchDirFD
								fromFilter:KQueueVNodeFilter];
		close(watchDirFD);
		watchDirFD = -1;
	}
}

- (void) setupWatchForPIDFile
{
	watchDirFD = open([[pidFile stringByDeletingLastPathComponent] fileSystemRepresentation], O_EVTONLY, 0);
	
	if (watchDirFD < 0)
		NSLog(@"Directory for pid does not exits!");
	else 
		[[KQueue sharedKQueue] addIdent:watchDirFD 
							 withFilter:KQueueVNodeFilter 
						 andFilterFlags:KQueueVNodeWriteFilterFlag];
}

- (void) setupWatchForPID
{
	pid_t pid = [[NSString stringWithContentsOfFile:pidFile] intValue];
	
	[[KQueue sharedKQueue] addIdent:pid 
						 withFilter:KQueueProcFilter 
					 andFilterFlags:KQueueProcessExitFilterFlag];
	watchPID = pid;
}

@end
