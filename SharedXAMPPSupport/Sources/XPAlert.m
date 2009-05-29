//
//  XPAlert.m
//  XAMPP Control
//
//  Created by Christian Speich on 29.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XPAlert.h"


@implementation XPAlert

+ (void) presentError:(NSError*)anError
{
	XPAlert* controller = [[self alloc] initWithError:anError];
	
	[controller runModal];
	
	[controller release];
}

- (id) initWithError:(NSError*)anError
{
	self = [super init];
	if (self != nil) {
		
		[self release];
		
		if ([[anError domain] isEqualToString:NSCocoaErrorDomain]
			&& [anError code] == NSUserCancelledError) {
			self = Nil;
		} else {
			NSAlert* alert;
			alert = [NSAlert alertWithError:anError];
			[alert setAlertStyle:NSCriticalAlertStyle];
			self = [alert retain];
		}
	}
	return self;
}

- (void) runModal
{
	
}

@end
