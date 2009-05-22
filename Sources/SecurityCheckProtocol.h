/*
 *  SecurityCheckProtocol.h
 *  XAMPP Control
 *
 *  Created by Christian Speich on 30.04.09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

@protocol SecurityCheckProtocol

- (void) calcualteTasks;

- (uint) tasks;
- (NSArray*) localizedTaskTitles;
- (BOOL) doTask:(uint)task;

@end
