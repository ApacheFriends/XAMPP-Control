//
//  XPViewController.m
//  XAMPP Control
//
//  Created by Christian Speich on 23.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XPViewController.h"


@implementation XPViewController

- (NSView*) view
{
	return view;
}

- (void) setView:(NSView*)aView
{
	NSParameterAssert(aView != Nil);
	
	if ([aView isEqual:view])
		return;
	
	[self willChangeValueForKey:@"view"];
	
	[view release];
	view = [aView retain];
	
	[self didChangeValueForKey:@"view"];
}

@end
