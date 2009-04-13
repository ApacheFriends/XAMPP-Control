/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Cocoa/Cocoa.h>


@interface XAMPPControls : NSWindowController {
	NSMutableArray	*modules;
	NSMutableArray	*moduleControllers;
	
	IBOutlet NSButton *betaButton;
	IBOutlet NSMenuItem *sendFeedback;
	IBOutlet NSMenuItem *menuBetaFeedback;
	
	IBOutlet NSMenu *modulesMenu;
}

- (IBAction) visitApacheForum:(id)sender;
- (IBAction) visitBugtracker:(id)sender;
- (IBAction) sendFeedback:(id)sender;

@end
