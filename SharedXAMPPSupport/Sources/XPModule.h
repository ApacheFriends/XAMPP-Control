//
//  XPModule.h
//  XAMPP Control
//
//  Created by Christian Speich on 03.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XPStatus.h"

@interface XPModule : NSObject {
	NSTimer *checkTimer;
	NSString *pidFile;
	XPStatus status;
	bool working;
	
	int watchDirFD;
	int watchPID;
}

// The Name of the Module
- (NSString*) name;

- (NSString*) pidFile;
- (void) setPidFile:(NSString*)aPidFile;

// The method is called on an seperate thread
// returns an NSError or nil if no error happens
- (NSError*) start;
- (NSError*) stop;
- (NSError*) reload;

- (XPStatus) status;
- (void) setStatus:(XPStatus) aStatus;

- (void) checkFixRightsAndRunIfNeeded;

- (void) refreshStatusCheck;
- (void) removeStatusCheck;
- (void) setupStatusCheck;

@end
