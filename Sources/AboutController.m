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
