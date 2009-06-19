/*
 
 XAMPP
 Copyright (C) 2009 by Apache Friends
 
 Authors of this file:
 - Christian Speich <kleinweby@apachefriends.org>
 
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

#import <XAMPP Control/XPPlugInHooks.h>
#import <PlugIn/PlugIn.h>

@implementation AboutController

- (NSString *)windowNibName
{
	return @"About";
}

- (IBAction)showWindow:(id)sender
{
	if (![self isWindowLoaded]) {
		[self loadWindow];
	
		[self setupContent];
	}
	
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
	creditsHTML = [[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:@"html"]];
	
	PlugInInvokeHook(AboutWindowSetupHook, 
					 [NSDictionary dictionaryWithObjectsAndKeys:
					  XAMPPString, HookXAMPPLabelKey,
					  versionsString, HookVersionsStringKey,
					  creditsHTML, HookCreditsHTMLKey,
					  [self window], HookWindowKey,
					  Nil]);
	
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
