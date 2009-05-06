//
//  App_Delegate.m
//  XAMPP Control
//
//  Created by Christian Speich on 22.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "App_Delegate.h"

#import <PlugIn/PlugIn.h>
#import <SharedXAMPPSupport/SharedXAMPPSupport.h>

#import "ModulesMenuController.h"
#import "ControlsWindowController.h"
#import "SecurityCheckController.h"
#import "AssistantPage.h"
#import "XPModuleErrorWindow.h"

@implementation App_Delegate

#pragma mark -
#pragma mark Getter and Setter

#pragma mark -
#pragma mark Application Setup

- (void) awakeFromNib
{
	NSError *error;
	PlugInManager *manager = [PlugInManager sharedPlugInManager];
	
	// Setup plugin categories
	[[manager registry] addCategorie:XPModulesPlugInCategorie];
	[[manager registry] addCategorie:XPControlsPlugInCategorie];
	[[manager registry] addCategorie:XPSecurityChecksPlugInCategorie];
	
	if (![[PlugInManager sharedPlugInManager] loadAllPluginsError:&error]) {
		[NSApp presentError:error];
	}
	
	NSLog(@"%@", [[manager registry] stringFromRegistryContent]);
		
	modulesMenuController = [[ModulesMenuController alloc] initWithMenu:modulesMenu];
	controlsWindowController = [[ControlsWindowController alloc] initWithWindowNibName:@"ControlsWindow"];
	securityCheckController = [[SecurityCheckController alloc] init];

	//[securityCheckController showWindow:self];
	
	[XPModuleErrorWindow presentError:[NSError errorWithDomain:@"" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"/Applications/XAMPP/xamppfiles/logs/error_log", @"LOGFILE", Nil]]];
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
