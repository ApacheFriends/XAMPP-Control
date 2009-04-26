//
//  AssistantController.h
//  XAMPP Control
//
//  Created by Christian Speich on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AssistantPage;
@class AssistantStepIndicatorView;

@interface AssistantController : NSWindowController {
	IBOutlet NSView*	pageView;
	IBOutlet NSButton*	backButton;
	IBOutlet NSButton*	forwardButton;
	IBOutlet AssistantStepIndicatorView* stepIndicatorView;
	
	IBOutlet NSArrayController *pagesController;
	
	NSArray*			pages;
	NSString*			title;
	AssistantPage*		currentPage;
}

- (NSArray*)pages;
- (void)setPages:(NSArray*)anArray;

- (NSString*) title;
- (void) setTitle:(NSString*)anString;

- (IBAction) forward:(id)sender;
- (IBAction) back:(id)sender;

@end
