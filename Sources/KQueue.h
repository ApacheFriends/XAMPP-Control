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

#import <Cocoa/Cocoa.h>
#include <sys/event.h>

extern NSString *KQueueNewEvent;
extern NSString *KQueueIdentKey;
extern NSString *KQueueFilterKey;
extern NSString *KQueueFlagsKey;
extern NSString *KQueueFilterFlagsKey;
extern NSString *KQueueFilterDataKey;

/* Filters */
extern NSString *KQueueReadFilter;
extern NSString *KQueueWriteFilter;
extern NSString *KQueueVNodeFilter;
extern NSString *KQueueProcFilter;
extern NSString *KQueueSignalFilter;

/* VNode Filter Flags */
#define KQueueVNodeDeleteFilterFlag (NOTE_DELETE)
#define KQueueVNodeWriteFilterFlag (NOTE_WRITE)
#define KQueueVNodeExtendFilterFlag (NOTE_EXTEND)
#define KQueueVNodeAttribFilterFlag (NOTE_ATTRIB)
#define KQueueVNodeLinkFilterFlag (NOTE_LINK)
#define KQueueVNodeRenameFilterFlag (NOTE_RENAME)
#define KQueueVNodeRevokeFilterFlag (NOTE_REVOKE)

/* Proc Filter Flags */
#define KQueueProcessExitFilterFlag (NOTE_EXIT)
#define KQueueProcessForkFilterFlag (NOTE_FORK)
#define KQueueProcessExecFilterFlag (NOTE_EXEC)

@interface KQueue : NSObject {
	int queueFD;
	NSMutableArray *watchedIdents;
	bool keepThreadRunning;
}

+ (id) sharedKQueue;
- (int) queueFD;

- (void) addIdent:(uint)aIdent withFilter:(NSString*)aFilter andFilterFlags:(uint) fflags;
- (void) removeIdent:(uint)aIdent fromFilter:(NSString*)aFilter;

- (uint) intFromFilter:(NSString*)aFilter;

@end
