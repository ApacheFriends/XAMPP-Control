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

#import "App_Delegate.h"

#import <PlugIn/PlugIn.h>
#import <XAMPP Control/XAMPP Control.h>

#import "ModulesMenuController.h"
#import "ControlsWindowController.h"
#import "SecurityCheckController.h"

@implementation App_Delegate

#pragma mark -
#pragma mark Getter and Setter

#pragma mark -
#pragma mark Application Setup

- (void) awakeFromNib
{
	NSError *error;
	PlugInManager *manager = [PlugInManager sharedPlugInManager];
	
	[manager setSearchPaths:[self plugInDirectories]];
	
	// Setup plugin categories
	[[manager registry] addCategorie:XPModulesPlugInCategorie];
	[[manager registry] addCategorie:XPControlsPlugInCategorie];
	[[manager registry] addCategorie:XPSecurityChecksPlugInCategorie];
	
	if (![manager loadAllPluginsError:&error]) {
		[NSApp presentError:error];
	}
	
	DLog(@"%@", [[manager registry] stringFromRegistryContent]);
		
	modulesMenuController = [[ModulesMenuController alloc] initWithMenu:modulesMenu];
	controlsWindowController = [[ControlsWindowController alloc] initWithWindowNibName:@"ControlsWindow"];
	securityCheckController = [[SecurityCheckController alloc] init];
	
	// Always show the Controls Window on startup
	[controlsWindowController showWindow:self];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return YES;
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
	[controlsWindowController showWindow:theApplication];
	
	return YES;
}

- (IBAction) showSecurityCheck:(id)sender
{
	[securityCheckController showWindow:sender];
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

- (NSArray*) plugInDirectories
{
	NSMutableArray* directories = [NSMutableArray array];
	NSArray* appSupportPaths;
	NSEnumerator* enumerator;
	NSString* path;
	
	[directories addObject:[[NSBundle mainBundle] builtInPlugInsPath]];
	
	appSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	enumerator = [appSupportPaths objectEnumerator];
	while ((path = [enumerator nextObject]))
		[directories addObject:[path stringByAppendingPathComponent:@"XAMPP Control/PlugIns"]];
		
	return directories;
}

@end
