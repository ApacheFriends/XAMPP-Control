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

#import "ControlsWindowController.h"

#import <PlugIn/PlugInRegistry.h>
#import <PlugIn/PlugInManager.h>
#import <XAMPP Control/XPPlugInCategories.h>
#import <XAMPP Control/XPViewController.h>
#import <XAMPP Control/XPPLugInHooks.h>

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
	
	PlugInInvokeHook(ControlsWindowDidLoadHook, 
					 [NSDictionary dictionaryWithObject:[self window] 
												 forKey:HookWindowKey]);
}

@end

@implementation ControlsWindowController (PRIVATE)

- (NSRect) contentFrame
{
	NSRect frame;
	NSArray *contols;
	NSEnumerator *enumerator;
	int maxWidth = 0;
	id object;
	
	frame = [[self window] frame];
	contols = [[[PlugInManager sharedPlugInManager] registry] objectsForCategorie:XPControlsPlugInCategorie];
	enumerator = [contols objectEnumerator];
	
	frame.size.height  = SPACE;
	
	while ((object = [enumerator nextObject])) {
		if ([object isKindOfClass:[XPViewController class]]) {
			if (maxWidth < NSWidth([[object view] frame]))
				maxWidth = NSWidth([[object view] frame]);
			frame.size.height += NSHeight([[object view] frame]);
			if (![object isEqual:[contols lastObject]])
				frame.size.height += SPACE;
		}
	}
	
	frame.size.width   = maxWidth + MARGIN*2;
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
	enumerator = [subviews objectEnumerator];
	
	while ((view = [enumerator nextObject]))
		[view removeFromSuperviewWithoutNeedingDisplay];
	
	[subviews release];
	
	controls = [[[PlugInManager sharedPlugInManager] registry] objectsForCategorie:XPControlsPlugInCategorie];
	enumerator = [controls objectEnumerator];
	
	y = NSHeight(contentFrame) - SPACE;
	
	while ((controller = [enumerator nextObject])) {
		
		if (![controller isKindOfClass:[XPViewController class]]) {
			DLog(@"%@ is not an XPViewController!", controls);
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
