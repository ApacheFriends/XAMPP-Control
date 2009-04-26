/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Cocoa/Cocoa.h>
#import <SharedXAMPPSupport/XPViewController.h>

@class XPModule;
@class StatusView;

@interface XPModuleViewController : XPViewController {
	IBOutlet NSButton	*actionButton;
	IBOutlet StatusView	*statusView;
	IBOutlet NSTextField*nameField;
	
	XPModule			*module;
	
	NSMenuItem			*startItem;
	NSMenuItem			*stopItem;
	NSMenuItem			*reloadItem;
}

- (id) initWithModule:(XPModule*) module;

- (IBAction) action:(id)sender;
- (IBAction) stop:(id)sender;
- (IBAction) start:(id)sender;
- (IBAction) reload:(id)sender;

- (NSArray*) menuItems;

@end
