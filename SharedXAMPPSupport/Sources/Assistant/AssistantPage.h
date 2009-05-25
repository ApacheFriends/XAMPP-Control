//
//  AssistantPage.h
//  XAMPP Control
//
//  Created by Christian Speich on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SharedXAMPPSupport/SharedXAMPPSupport.h>

typedef enum {
	AssistantNormalPage = 1,
	AssistantSummaryPage = 2,
	AssistantWorkPage = 3,
	AssistantFinishPage = 4,
	AssistantUnknownPage = 5
} AssistantPageType;

@class AssistantController;

@interface AssistantPage : XPViewController {
	AssistantPageType	type;
	AssistantController*assistantController;
	NSString*			title;
	NSString*			stepTitle;
}

- (AssistantPageType) type;
- (void) setType:(AssistantPageType)anType;

- (NSString*) title;
- (void) setTitle:(NSString*)anTitle;

- (NSString*) stepTitle;
- (void) setStepTitle:(NSString*)anStepTitle;

- (AssistantController*) assistantController;
- (void) setAssistantController:(AssistantController*)anController;

- (void) pageWillAppear;
- (void) pageDidAppear;
- (void) pageWillDisappear;
- (void) pageDidDisappear;

// Is the pagecontent valid so that the page can disappear and show the next page
// The error presentation is the task of the assistant page
- (BOOL) valid;

@end
