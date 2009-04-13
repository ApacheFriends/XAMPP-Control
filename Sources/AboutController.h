//
//  AboutController.h
//  XAMPP Control
//
//  Created by Christian Speich on 03.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AboutController : NSWindowController {
	IBOutlet	NSTextField *XAMPPName;
	IBOutlet	NSTextField *versionsField;
	
	IBOutlet	WebView		*webView;
}

- (void) setupContent;

@end
