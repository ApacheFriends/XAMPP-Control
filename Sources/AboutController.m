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

#import <PlugIn/PlugIn.h>

@implementation AboutController

- (id) init
{
	self = [super init];
	if (self != nil) {
		/*if (![NSBundle loadNibNamed:@"About" owner:self]) {
			[self release];
			return nil;
		}
		
		[self setupContent];*/
		NSLog(@"owner %@", [self owner]);
	}
	return self;
}

- (NSString *)windowNibName
{
	return @"About";
}

- (IBAction)showWindow:(id)sender
{
	if (![self isWindowLoaded])
		[self loadWindow];
	
	[self setupContent];
	
	return [super showWindow:sender];
}

- (void) setupContent
{
	NSMutableAttributedString* versionsString;
	NSMutableAttributedString* XAMPPString;
	NSMutableString* creditsHTML;
	NSMutableParagraphStyle* centeredParagraphStyle;
	
	centeredParagraphStyle = [NSMutableParagraphStyle new];
	[centeredParagraphStyle setAlignment:NSCenterTextAlignment];
	
	XAMPPString = [[XAMPPName attributedStringValue] mutableCopy];
	versionsString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Version %@", [XPConfiguration version]]
															attributes:[NSDictionary dictionaryWithObject:centeredParagraphStyle forKey:NSParagraphStyleAttributeName]];
	creditsHTML = [[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Team" ofType:@"html"]];
	
	PlugInInvokeHook(@"SetupAboutContent", [NSDictionary dictionaryWithObjectsAndKeys:XAMPPString,@"XAMPPString",versionsString,@"versionString",creditsHTML,@"creditsHTML",Nil]);
	
	[XAMPPName setAttributedStringValue:XAMPPString];
	[versionsField setAttributedStringValue:versionsString];
	[[webView mainFrame] loadHTMLString:creditsHTML 
								baseURL:Nil];
	
	[versionsString release];
	[XAMPPString release];
	[creditsHTML release];
	[centeredParagraphStyle release];
}

@end
