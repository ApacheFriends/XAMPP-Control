//
//  PHPSwitchControl.h
//  XAMPP Control
//
//  Created by Christian Speich on 16.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SharedXAMPPSupport/SharedXAMPPSupport.h>
#import <PlugIn/PlugIn.h>

@interface PHPSwitchControl : XPViewController<PlugInPriorityProtocol> {
	IBOutlet StatusIndicatorView* statusIndicator;
	IBOutlet NSPopUpButton* phpVersionSwitch;
	
}

- (void) updatePHPVersionsMenu;

@end
