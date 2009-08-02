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

@implementation App_Delegate

+ (void)initialize{
	
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
								 dictionaryWithObject:@"NO" forKey:@"SkipLocationCheck"];
	
    [defaults registerDefaults:appDefaults];
}

#pragma mark -
#pragma mark Getter and Setter

#pragma mark -
#pragma mark Application Setup

- (void) awakeFromNib
{
	[self installLocationCheck];

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
			
	modulesMenuController = [[ModulesMenuController alloc] initWithMenu:modulesMenu];
	controlsWindowController = [[ControlsWindowController alloc] initWithWindowNibName:@"ControlsWindow"];
	
	// Always show the Controls Window on startup
	[controlsWindowController showWindow:self];
	[[controlsWindowController window] makeKeyAndOrderFront:self];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return YES;
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
	[self showControlsWindow:theApplication];
	
	return YES;
}

- (void) installLocationCheck
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"SkipLocationCheck"])
		return;
	
	NSString* currentPath = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
	NSString* xamppPath = [[XPConfiguration XAMPPPath] stringByResolvingSymlinksInPath];
	
	if (![currentPath isEqualToString:xamppPath]) {
		NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedString(@"WorngInstallLocation", @"Alert Message for the Wrong Install Location error")
										 defaultButton:NSLocalizedString(@"OK", @"OK") 
									   alternateButton:NSLocalizedString(@"InstallGuideButton", @"Button Title for the Install Guide")
										   otherButton:Nil 
							 informativeTextWithFormat:NSLocalizedString(@"WorngInstallLocationDescription", @"Alert Message Description for the Wrong Install Location error")];
		[alert setAlertStyle:NSCriticalAlertStyle];
		int choice = [alert runModal];
		
		if (choice == NSAlertAlternateReturn) {
			[[NSWorkspace sharedWorkspace] openURL:[[XPConfiguration sharedConfiguration] installGuideURL]];
		}
		
		[NSApp terminate:self];
	}
}

- (IBAction) showControlsWindow:(id)sender
{
	[controlsWindowController showWindow:sender];
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
