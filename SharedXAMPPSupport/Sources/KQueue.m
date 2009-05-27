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

#import "KQueue.h"
#include <unistd.h>

static id sharedKQueue;

NSString *KQueueNewEvent = @"KQueueNewEvent";
NSString *KQueueIdentKey = @"KQueueIdentKey";
NSString *KQueueFilterKey = @"KQueueFilterKey";
NSString *KQueueFlagsKey = @"KQueueFalgsKey";
NSString *KQueueFilterFlagsKey = @"KQueuetFilterFlagsKey";
NSString *KQueueFilterDataKey = @"KQueueFilterDataKey";

/* Filters */
NSString *KQueueReadFilter = @"KQueueReadFilter";
NSString *KQueueWriteFilter = @"KQueueWriteFilter";
NSString *KQueueVNodeFilter = @"KQueueVNodeFilter";
NSString *KQueueProcFilter = @"KQueueProcFilter";
NSString *KQueueSignalFilter = @"KQueueSignalFilter";

@implementation KQueue

+ (id) allocWithZone:(NSZone*)zone
{
	if (!sharedKQueue)
		sharedKQueue = [super allocWithZone:zone];
	return nil;
}

+ (id) sharedKQueue
{
	if (!sharedKQueue) {
		[self alloc];
		[sharedKQueue init];
	}
	
	return sharedKQueue;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		queueFD = kqueue();
		if( queueFD == -1 )
		{
			[NSException raise:@"KQueue create faild" format:@"creating a kqueue faild with '%s'(%i)", strerror(errno), errno];
			[self release];
			return nil;
		}
		
		watchedIdents = [[NSMutableArray alloc] init];
		keepThreadRunning = YES;
		[NSThread detachNewThreadSelector:@selector(watcherThread) toTarget:self withObject:nil];
	}
	return self;
}

-(void) release
{
}

- (uint) retainCount
{
	return UINT_MAX;
}

- (int) queueFD
{
	return queueFD;
}

- (void) addIdent:(uint)aIdent withFilter:(NSString*)aFilter andFilterFlags:(uint) fflags
{
	struct timespec	timeout = { 0, 0 };
	struct kevent	event;
	
	EV_SET(&event, aIdent, 
	       [self intFromFilter:aFilter], 
	       EV_ADD | EV_ENABLE | EV_CLEAR,
		   fflags, 0, NULL);
	
	kevent(queueFD, &event, 1, NULL, 0, &timeout);
}

- (void) removeIdent:(uint)aIdent fromFilter:(NSString*)aFilter
{
	NSParameterAssert(aFilter != Nil);
	
	struct timespec	timeout = { 0, 0 };
	struct kevent	event;
	NSLog(@"Remove %i", aIdent);
	EV_SET(&event, aIdent, 
	       [self intFromFilter:aFilter], 
	       EV_DELETE | EV_CLEAR,
		   UINT_MAX, 0, NULL);
	
	kevent(queueFD, &event, 1, NULL, 0, &timeout);
}

- (uint) intFromFilter:(NSString*)aFilter
{
	NSParameterAssert(aFilter != Nil);
	
	if ([aFilter isEqualToString:KQueueReadFilter])
		return EVFILT_READ;
	else if ([aFilter isEqualToString:KQueueWriteFilter])
		return EVFILT_WRITE;
	else if ([aFilter isEqualToString:KQueueVNodeFilter])
		return EVFILT_VNODE;
	else if ([aFilter isEqualToString:KQueueProcFilter])
		return EVFILT_PROC;
	else if ([aFilter isEqualToString:KQueueSignalFilter])
		return EVFILT_SIGNAL;
	return UINT_MAX;
}

- (void) watcherThread
{
	int					n;
    struct kevent		ev;
    struct timespec     timeout = { 5, 0 };
	int					theFD = queueFD;
	NSMutableDictionary *event;
	
	while (keepThreadRunning) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		@try {
			n = kevent(theFD, NULL, 0, &ev, 1, &timeout);
			if (n < 0)
				[NSException raise:@"kevent error" format:@"%i: %s", errno, strerror(errno)];
			else if (n > 0) {
				event = [[NSMutableDictionary alloc] init];
				
				[event setValue:[NSNumber numberWithInt:ev.ident] forKey:KQueueIdentKey];
				switch (ev.filter) {
					case EVFILT_READ:
						[event setValue:KQueueReadFilter forKey:KQueueFilterKey];
						break;
					case EVFILT_WRITE:
						[event setValue:KQueueWriteFilter forKey:KQueueFilterKey];
						break;
					case EVFILT_VNODE:
						[event setValue:KQueueVNodeFilter forKey:KQueueFilterKey];
						break;
					case EVFILT_PROC:
						[event setValue:KQueueProcFilter forKey:KQueueFilterKey];
						break;
					case EVFILT_SIGNAL:
						[event setValue:KQueueSignalFilter forKey:KQueueFilterKey];
						break;
					default:
						[NSException raise:@"Unknown kevent filter" format:@"filter %i", ev.filter];
						break;
				}
				
				[event setValue:[NSNumber numberWithInt:ev.fflags] forKey:KQueueFilterFlagsKey];
								
				[[NSNotificationCenter defaultCenter] postNotificationName:KQueueNewEvent 
																	object:self 
																  userInfo:event];
				
				[event release];
			}
		}
		@catch (NSException * e) {
			NSLog(@"Ignoring Exception in [%@ watcherThread]: %@", [self className], e);
		}
		@finally {
			[pool release];
		}
	}
	
	if(close(theFD) == -1)
		NSLog(@"KQueue: Couldn't close main kqueue (%d)", errno);
}

@end
