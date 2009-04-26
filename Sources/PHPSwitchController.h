//
//  PHPSwitchController.h
//  XAMPP Control
//
//  Created by Christian Speich on 10.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PHPSwitchController : NSObject {
	IBOutlet NSView		*view;
	IBOutlet NSPopUpButton	*phpSelector;
	
	NSMenu   *phpMenu;
	int		phpIndex;
}

- (NSView*) view;

- (void) updateMenu;

- (IBAction) switchPHP:(id)sender;

@end
