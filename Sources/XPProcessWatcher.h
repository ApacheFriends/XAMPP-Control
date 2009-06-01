//
//  XPProcessWatcher.h
//  XAMPP Control
//
//  Created by Christian Speich on 30.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XPProcessWatcher : NSObject {
	NSString*	pidFile;
	id			delegate;
	
	int			status;
	
	int			watchDirFD;
	int			watchPID;
}

- (NSString*) pidFile;
- (void) setPidFile:(NSString*)pidFile;

- (id) delegate;
- (void) setDelegate:(id)anDelegate;

- (void) forceCheckNow;

@end
