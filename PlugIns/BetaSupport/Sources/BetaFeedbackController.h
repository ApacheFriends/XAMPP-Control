/*
 
 XAMPP
 Copyright (C) 2009 by Apache Friends
 
 Authors of this file:
 - Christian Speich <kleinweby@apachefriends>
 
 This file is part of XAMPP.
 
 XAMPP is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 XAMPP is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with XAMPP.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#import <Cocoa/Cocoa.h>

/* Mal ein kleiner code schnipsel aus dem alten cp
 
 id superview = [[[self window] standardWindowButton:NSWindowCloseButton] superview];
 NSRect frame;
 
 frame.size = [betaButton frame].size;
 //frame.origin.y = -1.f + NSMaxY([superview frame]) - (frame.size.height + ceil((NSHeight([[self window] frame]) - NSHeight([[[self window] contentView] frame]) - NSHeight([NSWindow contentRectForFrameRect:[[self window] frame] styleMask:[[self window] styleMask]]) - NSHeight([[[self window] contentView] frame]) - frame.size.height) / 2.0));
 frame.origin.y = NSHeight([superview frame]) - NSHeight(frame) - 5.f;
 frame.origin.x = NSMaxX([superview frame]) - frame.size.width - 5.f;
 [betaButton setFrame:frame];
 [betaButton setToolTip:@"You have an Beta Version of XAMPP. Please send us Feedback."];
 [superview addSubview:betaButton];
 
 NSLog(@"frame %@ betaButton %@", NSStringFromRect(frame), betaButton);
 NSLog(@"frame %@", NSStringFromRect([superview frame]));
 
 */


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
