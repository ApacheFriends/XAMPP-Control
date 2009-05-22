//
//  StatusIndicatorView.h
//  XAMPP Control
//
//  Created by Christian Speich on 16.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum _StatusIndicator {
	GreenStatus,
	YellowStatus,
	RedStatus,
	WorkingStatus,
	NoStatus,
	UnknownStatus
};

typedef enum _StatusIndicator StatusIndicator;

@interface StatusIndicatorView : NSView {
	StatusIndicator status;
	NSProgressIndicator *progressIndicator;
	
	NSImage *greenImage;
	NSImage *yellowImage;
	NSImage *redImage;
	NSImage *unknownImage;
}

- (StatusIndicator) status;
- (void) setStatus:(StatusIndicator)status;

@end
