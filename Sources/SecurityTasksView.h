//
//  SecurityTasksView.h
//  XAMPP Control
//
//  Created by Christian Speich on 17.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum _SecurityTaskStatus {
	SecurityTaskNoStatus = 1,
	SecurityTaskWorkingStatus,
	SecurityTaskSuccessStatus,
	SecurityTaskFailStatus,
	SecurityTaskUnknownStatus
};

typedef enum _SecurityTaskStatus SecurityTaskStatus;

@interface SecurityTasksView : NSView {
	NSArray* tasks;
	NSMutableArray* taskViews;
	
	NSArray* taskInformations;
}

- (void) setTasks:(NSArray*)anArray;
- (NSArray*) tasks;

- (SecurityTaskStatus) statusForTask:(uint)task;
- (void) setStatus:(SecurityTaskStatus)status forTask:(uint)task;

@end
