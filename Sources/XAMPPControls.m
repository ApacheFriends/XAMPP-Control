/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "XAMPPControls.h"

#import <SharedXAMPPSupport/SharedXAMPPSupport.h>
#import <PlugIn/PlugIn.h>

@interface XAMPPControls (PRIVAT)

- (void) setupModules;
- (void) setupModuleViews;
- (void) setupBeta;

- (NSRect) calculateWindowFrame;

- (NSButton *)addButtonToTitleBarWithSize:(NSSize)size;
- (float)titleBarHeight;
- (float)toolbarHeight;

@end

#define SPACE (8)
#define MARGIN (17)

@implementation XAMPPControls

- (id) init
{
	self = [super init];
	if (self != nil) {
		modules = [[NSMutableArray alloc] init];
		moduleControllers = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[modules release];
	[moduleControllers release];
	
	[super dealloc];
}


- (void) awakeFromNib
{
	[self setupModules];
	[self setupModuleViews];

	if ([XPConfiguration isBetaVersion])
		[self setupBeta];
	else
		[[menuBetaFeedback menu] removeItem:menuBetaFeedback];
	
	[[self window] makeKeyAndOrderFront:self];
	
	[[XPConfiguration sharedConfiguration] updatePHPVersions];
	
	PlugInManager *plugInManager = [PlugInManager new];
	NSError *error = Nil;
	
	[plugInManager loadAllPluginsError:&error];
	
	NSLog(@"%@", error);
}

- (void) setupModules
{
}

- (void) setupModuleViews
{
	// Calculate Window Height
	NSRect frame = [self calculateWindowFrame];
	int height = NSHeight(frame);
	
	[[self window] setFrame:[[self window] frameRectForContentRect:frame] display:NO animate:NO];
	
	height -= MARGIN;
	
	int i, count = [modules count];
	for (i = 0; i < count; i++) {
		XPModule * module = [modules objectAtIndex:i];
		ModuleViewController *controller = [[ModuleViewController alloc] initWithModule:module];
		NSArray *menuItems = [controller menuItems];
		
		height -= [[controller view] frame].size.height;
		
		[[controller view] setFrameOrigin:NSMakePoint(17, height)];
		[[[self window] contentView] addSubview:[controller view]];
		
		height -= SPACE;
		
		for (int i = 0; i < [menuItems count]; i++)
			[modulesMenu addItem:[menuItems objectAtIndex:i]];
		
		if (i != count - 1)
			[modulesMenu addItem:[NSMenuItem separatorItem]];
				
		[moduleControllers addObject:controller];
		[controller release];
	}
	
	if ([[[XPConfiguration sharedConfiguration] PHPVersions] count] > 1) {
		PHPSwitchController *controller = [[PHPSwitchController alloc] init];
		
		height -= [[controller view] frame].size.height;
		[[controller view] setFrameOrigin:NSMakePoint(17, height)];
		[[[self window] contentView] addSubview:[controller view]];
		height -= SPACE;
	}
}

- (NSRect) calculateWindowFrame
{
	NSRect frame = [[self window] frame];
	int height = 0;
	
	height += 2*MARGIN;
	height += 25.f * [modules count];
	height += SPACE * ([modules count] -1);
	
	if ([[[XPConfiguration sharedConfiguration] PHPVersions] count] > 1)
		height += 25.f + SPACE;
	
	frame.size.height = height;
	return frame;
}

- (void) setupBeta
{
	id superview = [[[self window] standardWindowButton:NSWindowCloseButton] superview];
	NSRect frame;
    
    frame.size = [betaButton frame].size;
    frame.origin.y = -1.f + NSMaxY([superview frame]) - (frame.size.height + ceil(([self titleBarHeight] - frame.size.height) / 2.0));
    frame.origin.x = NSMaxX([superview frame]) - frame.size.width - 5.f;
    [betaButton setFrame:frame];
	[betaButton setToolTip:@"You have an Beta Version of XAMPP. Please send us Feedback."];
	[superview addSubview:betaButton];
	
	[[sendFeedback menu] removeItem:sendFeedback];
}

- (float)toolbarHeight
{
    return NSHeight([NSWindow contentRectForFrameRect:[[self window] frame] styleMask:[[self window] styleMask]]) - NSHeight([[[self window] contentView] frame]);
}

- (float)titleBarHeight
{
    return NSHeight([[self window] frame]) - NSHeight([[[self window] contentView] frame]) - [self toolbarHeight];
}

#pragma mark -
#pragma mark Feedback

- (IBAction) visitApacheForum:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[[XPConfiguration sharedConfiguration] supportForumURL]];
}

- (IBAction) visitBugtracker:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[[XPConfiguration sharedConfiguration] bugtrackerURL]];
}

- (IBAction) sendFeedback:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"mailto:kleinweby@apachefriends.org?subject=XAMPP for Mac OS X %@ Feedback", [XPConfiguration version]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

@end
