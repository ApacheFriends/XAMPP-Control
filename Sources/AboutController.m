//
//  AboutController.m
//  XAMPP Control
//
//  Created by Christian Speich on 03.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutController.h"
#import "XPConfiguration.h"

@implementation AboutController

- (id) init
{
	self = [super init];
	if (self != nil) {
		if (![NSBundle loadNibNamed:@"About" owner:self]) {
			[self release];
			return nil;
		}
		
		[self setupContent];
	}
	return self;
}

- (void) setupContent
{
	if ([XPConfiguration isBetaVersion] && NO) {
		NSMutableAttributedString *name = [[XAMPPName attributedStringValue] mutableCopy];
		NSMutableAttributedString *beta = [[NSMutableAttributedString alloc] initWithString:@"Beta"];
		
		[beta setAttributes:[NSDictionary dictionaryWithObjectsAndKeys:	[NSColor redColor],@"NSColor",
																		[NSNumber numberWithFloat:0.3], NSObliquenessAttributeName,
																		[NSFont boldSystemFontOfSize:12.f], NSFontAttributeName, Nil]
					  range:NSMakeRange(0, [beta length])];
		[name appendAttributedString:beta];
				
		[XAMPPName setAttributedStringValue:name];
		[name release];
		[beta release];
	}
	
	[versionsField setStringValue:[NSString stringWithFormat:@"Version %@", [XPConfiguration version]]];
	
	[[webView mainFrame] loadHTMLString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Team" ofType:@"html"]] 
								baseURL:Nil];
}

@end
