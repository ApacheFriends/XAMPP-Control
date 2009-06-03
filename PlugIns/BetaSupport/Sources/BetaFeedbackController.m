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

#import "BetaFeedbackController.h"
#import "XPConfiguration.h"
#include <sys/sysctl.h>

@implementation BetaFeedbackController

- (id) init
{
	self = [super init];
	if (self != nil) {
		if (![NSBundle loadNibNamed:@"BetaFeedback" owner:self]) {
			[self release];
			return nil;
		}
		
		betaFeedbackURL = [[NSURL alloc] initWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"BetaFeedbackURL"]];
		hasSendFeedback = NO;
	}
	return self;
}

- (void) awakeFromNib
{
	extraInformationsViewSize = [extraInformationsView frame].size;
	NSLog(@"rect %@", NSStringFromRect([extraInformationsView frame]));
	[self disclosureTrianglePressed:extraInformationsDisclosure];
}

- (void) showWindow:(id)sender
{
	hasSendFeedback = YES;
	[self clearFields];
	
	[[self window] makeFirstResponder:feedbackText];
	[super showWindow:self];
}

- (IBAction) sendOrClose:(id)sender
{
	if (hasSendFeedback)
		[self close];
	else
		[self sendFeedback];
}

- (IBAction)test:(id)sender
{
	NSLog(@"test");
}

- (IBAction)disclosureTrianglePressed:(id)sender {
    NSWindow *window = [sender window];
    NSRect frame = [window frame];
    // The extra +14 accounts for the space between the box and its neighboring views
    float sizeChange = extraInformationsViewSize.height;
	NSLog(@"changed %f", sizeChange);
	BOOL hidden;
	NSLog(@"rect %@", NSStringFromRect([extraInformationsView frame]));
    switch ([sender state]) {
        case NSOnState:
            // Show the extra box.
            //[extraInformationsView setHidden:NO];
			hidden = NO;
			NSLog(@"show");
            // Make the window bigger.
            frame.size.height += sizeChange;
            // Move the origin.
            frame.origin.y -= sizeChange;
            break;
        case NSOffState:
            // Hide the extra box.
			hidden = YES;
            [extraInformationsView setHidden:YES];
            // Make the window smaller.
            frame.size.height -= sizeChange;
            // Move the origin.
			NSLog(@"hide");
            frame.origin.y += sizeChange;
            break;
        default:
            break;
    }
	
    [window setFrame:frame display:YES animate:YES];
	[extraInformationsView setHidden:hidden];
}

- (void) sendFeedback
{
	NSMutableString *formString;
	NSMutableURLRequest *feedbackRequest;
	NSString *stringBoundary = @"0xXaMpPfEeDbAcKbOuNdArY";

	[sendOrCloseButton setEnabled:NO];
	[feedbackText setEditable:NO];
	[feedbackEMail setEnabled:NO];
	[includeSystemVersion setEnabled:NO];
	
	[progressIndicator setHidden:NO];
	[progressIndicator startAnimation:self];
	[progressText setStringValue:@"Sending Feedback... Thank you!"];
	[progressText setHidden:NO];
	
	formString = [NSMutableString string];
	feedbackRequest = [NSMutableURLRequest requestWithURL:betaFeedbackURL];
	
	[feedbackRequest setHTTPMethod:@"POST"];
	[feedbackRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary]
		   forHTTPHeaderField: @"Content-Type"]; 
	
	/* Version */
	[formString appendFormat:@"\r\n\r\n--%@\r\n",stringBoundary];
	[formString appendFormat:@"Content-Disposition: form-data; name=\"version\"\r\n\r\n"];
	[formString appendFormat:@"XAMPP for Mac OS X %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
	
	/* E Mail */
	[formString appendFormat:@"\r\n--%@\r\n",stringBoundary];
	[formString appendFormat:@"Content-Disposition: form-data; name=\"email\"\r\n\r\n"];
	[formString appendFormat:@"%@", [feedbackEMail stringValue]];
	
	/* To pass trough the spam check of the feedback skript */
	[formString appendFormat:@"\r\n--%@\r\n",stringBoundary];
	[formString appendFormat:@"Content-Disposition: form-data; name=\"zaphod\"\r\n\r\n"];
	[formString appendFormat:@"cool"];
	
	/* To pass trough the spam check of the feedback skript */
	[formString appendFormat:@"\r\n--%@\r\n",stringBoundary];
	[formString appendFormat:@"Content-Disposition: form-data; name=\"language\"\r\n\r\n"];
	[formString appendFormat:@"en"];
	
	/* Feedback Message */
	[formString appendFormat:@"\r\n--%@\r\n",stringBoundary];
	[formString appendFormat:@"Content-Disposition: form-data; name=\"text\"\r\n\r\n"];
	[formString appendFormat:[self buildFeedbackMessage]];
	
	[feedbackRequest setHTTPBody:[formString dataUsingEncoding:NSUTF8StringEncoding]];
	
	feedbackConnection = [[NSURLConnection alloc] initWithRequest:feedbackRequest delegate:self];
}

- (NSString*) buildFeedbackMessage
{
	NSMutableString *message = [NSMutableString string];
	
	[message appendString:@"==Feedback out of XAMPP Control==\r\n\r\n"];
	[message appendFormat:@" Version: %@\r\n", [XPConfiguration version]];
	[message appendFormat:@" System Version: %@\r\n", ([includeSystemVersion intValue] == 1)?[self systemVersion]:@"Unknown"];
	[message appendFormat:@" System Arch: %@\r\n\r\n", ([includeSystemVersion intValue] == 1)?[self systemArch]:@"Unknown"];
	[message appendString:@"=Feedback Message=\r\n"];
	
	[message appendString:[feedbackText string]];
	
	return message;
}

- (NSString*) systemVersion
{
	NSDictionary *systemVersion = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
	return [NSString stringWithFormat:@"%@ (%@)", [systemVersion objectForKey:@"ProductVersion"], [systemVersion objectForKey:@"ProductBuildVersion"]];
}

- (NSString*) systemArch
{
	OSErr err;
	int value = 0;
	unsigned long length = sizeof(value);
	
	err = sysctlbyname("hw.cputype", &value, &length, NULL, 0);
	if (err)
		return @"Unknown";
	
	switch (value) {
		case CPU_TYPE_X86:
			return @"i386";
			break;
		case CPU_TYPE_POWERPC:
			return @"ppc";
			break;
		default:
			return [NSString stringWithFormat:@"Unknown (%i)", value];
			break;
	}
}

#pragma mark -
#pragma mark URL Loading things

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// Yeah we've sucessfully send the feedback
	[sendOrCloseButton setEnabled:YES];
	[sendOrCloseButton setTitle:@"Close"];
	hasSendFeedback = YES;
	
	[progressIndicator setHidden:YES];
	[progressIndicator stopAnimation:self];
	[progressText setHidden:NO];
	[progressText setStringValue:@"Thank you for sending!"];
		
	//NSLog(@"Response: %@", [[[NSString alloc] initWithData:returnedData encoding:NSUTF8StringEncoding] autorelease]);
//	[returnedData release];
	[feedbackConnection release];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{	
	[sendOrCloseButton setEnabled:YES];
	[sendOrCloseButton setTitle:@"Close"];
	hasSendFeedback = YES;
	
	[progressIndicator setHidden:YES];
	[progressIndicator stopAnimation:self];
	[progressText setHidden:YES];
	
	//NSLog(@"error %@", error);
	
	[NSApp presentError:error];
	[feedbackConnection release];
}

- (void) clearFields
{
	[sendOrCloseButton setTitle:@"Send Feedback"];
	[sendOrCloseButton setEnabled:YES];
	[feedbackEMail setStringValue:@""];
	[feedbackEMail setEnabled:YES];
	[feedbackText setString:@""];
	[feedbackText setEditable:YES];
	
	hasSendFeedback = NO;
}

@end
