//
//  ControlsWindowController.m
//  XAMPP Control
//
//  Created by Christian Speich on 23.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ControlsWindowController.h"

#import <PlugIn/PlugInRegistry.h>
#import <PlugIn/PlugInManager.h>
#import <SharedXAMPPSupport/XPPlugInCategories.h>
#import <SharedXAMPPSupport/XPViewController.h>

#define SPACE (8)
#define MARGIN (17)

@interface ControlsWindowController (PRIVATE)

- (NSRect) contentFrame;
- (void) updateContent;

@end


@implementation ControlsWindowController

- (void) awakeFromNib
{
	[[self window] setFrame:[[self window] frameRectForContentRect:[self contentFrame]] display:YES animate:NO];
	[self updateContent];
	PlugInInvokeHook(@"controlsWindowDidLoad", [NSDictionary dictionaryWithObject:[self window] forKey:@"window"]);
}

@end

@implementation ControlsWindowController (PRIVATE)

- (NSRect) contentFrame
{
	NSRect frame;
	NSArray *contols;
	NSEnumerator *enumerator;
	id object;
	
	frame = [[self window] frame];
	contols = [[[PlugInManager sharedPlugInManager] registry] objectsForCategorie:XPControlsPlugInCategorie];
	enumerator = [contols objectEnumerator];
	
	frame.size.height  = SPACE;
	
	while ((object = [enumerator nextObject])) {
		if ([object isKindOfClass:[XPViewController class]]) {
			frame.size.height += NSHeight([[object view] frame]);
			if (![object isEqual:[contols lastObject]])
				frame.size.height += SPACE;
		}
	}
	
	frame.size.height += MARGIN;
	
	return frame;
}

- (void) updateContent
{
	NSArray *subviews;
	NSArray *controls;
	NSEnumerator *enumerator;
	NSView *view;
	NSRect contentFrame;
	NSRect viewFrame;
	XPViewController *controller;
	int y;
	int x = MARGIN;
	
	contentFrame = [self contentFrame];

	[[self window] setFrame:[[self window] frameRectForContentRect:contentFrame] display:YES animate:YES];
	
	subviews = [[[[self window] contentView] subviews] copy];
	enumerator = [[[[self window] contentView] subviews] objectEnumerator];
	
	while ((view = [enumerator nextObject]))
		[view removeFromSuperviewWithoutNeedingDisplay];
	
	[subviews release];
	
	controls = [[[PlugInManager sharedPlugInManager] registry] objectsForCategorie:XPControlsPlugInCategorie];
	enumerator = [controls objectEnumerator];
	
	y = NSHeight(contentFrame) - SPACE;
	
	while ((controller = [enumerator nextObject])) {
		
		if (![controller isKindOfClass:[XPViewController class]]) {
			NSLog(@"%p is not an XPViewController!", controls);
			continue;
		}
		
		view = [controller view];
		
		viewFrame = [view frame];
		
		y -= NSHeight(viewFrame);
		
		viewFrame.origin.y = y;
		viewFrame.origin.x = x;
		viewFrame.size.width = NSWidth(contentFrame) - 2*MARGIN;
		
		[view setFrame:viewFrame];
		[view setAutoresizingMask:NSViewWidthSizable];
		
		[[[self window] contentView] addSubview:view];
		
		y -= SPACE;
	}
}

@end
