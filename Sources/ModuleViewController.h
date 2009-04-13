/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Cocoa/Cocoa.h>

@class XPModule;
@class StatusView;

@interface ModuleViewController : NSObject {
	IBOutlet NSView		*view;
	IBOutlet NSButton	*actionButton;
	IBOutlet StatusView	*statusView;
	IBOutlet NSTextField*nameField;
	
	XPModule			*module;
	
	NSMenuItem			*startItem;
	NSMenuItem			*stopItem;
	NSMenuItem			*reloadItem;
}

- (id) initWithModule:(XPModule*) module;

- (NSView*) view;

- (IBAction) action:(id)sender;
- (IBAction) stop:(id)sender;
- (IBAction) start:(id)sender;
- (IBAction) reload:(id)sender;

- (NSArray*) menuItems;

@end
