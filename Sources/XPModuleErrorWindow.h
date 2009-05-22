//
//  XPModuleErrorWindow.h
//  XAMPP Control
//
//  Created by Christian Speich on 06.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XPModuleErrorWindow : NSWindowController {
	IBOutlet NSTextField*	titleField;
	IBOutlet NSTextField*	descriptionField;
	IBOutlet NSTextView*	logView;
	
	NSError*				error;
}

+ (id) presentError:(NSError*)anError;

- (id) initWithError:(NSError*)anError;

- (IBAction) ok:(id)sender;

@end
