//
//  BetaFeedbackController.h
//  XAMPP Control
//
//  Created by Christian Speich on 22.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BetaFeedbackController : NSWindowController {
	IBOutlet	NSTextView	*feedbackText;
	IBOutlet	NSTextField	*feedbackEMail;
	IBOutlet	NSButton	*includeSystemVersion;
	
	IBOutlet	NSProgressIndicator *progressIndicator;
	IBOutlet	NSTextField	*progressText;
	IBOutlet	NSButton	*sendOrCloseButton;
	
	NSURL					*betaFeedbackURL;
	
	NSMutableData			*returnedData;
	NSURLConnection			*feedbackConnection;
	
	bool					hasSendFeedback;
}

- (IBAction) sendOrClose:(id)sender;
- (void) sendFeedback;
- (NSString*) buildFeedbackMessage;

- (NSString*) systemVersion;
- (NSString*) systemArch;

- (void) clearFields;

@end
