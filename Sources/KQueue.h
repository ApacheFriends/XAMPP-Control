/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
