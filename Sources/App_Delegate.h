//
//  App_Delegate.h
//  XAMPP Control
//
//  Created by Christian Speich on 22.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PlugInManager;
@class ModulesMenuController;
@class ControlsWindowController;
@class SecurityCheckController;

@interface App_Delegate : NSObject {
	IBOutlet NSMenu* modulesMenu;
	
	ModulesMenuController* modulesMenuController;
	ControlsWindowController* controlsWindowController;
	SecurityCheckController* securityCheckController;
}

- (IBAction) visitApacheForum:(id)sender;
- (IBAction) visitBugtracker:(id)sender;
- (IBAction) sendFeedback:(id)sender;

@end
