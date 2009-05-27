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

#import "GettingStartedController.h"


@implementation GettingStartedController

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary
								 dictionaryWithObject:@"YES" forKey:@"showGettingStartedWindowAtStartup"];
	
    [defaults registerDefaults:appDefaults];
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		if (![NSBundle loadNibNamed:@"GettingStarted" owner:self]) {
			[self release];
			return nil;
		}
				
		[self setupContent];
		
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showGettingStartedWindowAtStartup"])
			[self showWindow:self];
	}
	return self;
}

- (void) setupContent
{
	NSMutableString *htmlCode;
	
	htmlCode = [[NSMutableString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GettingStarted" ofType:@"html"]];
	
	[htmlCode replaceOccurrencesOfString:@"#USER#" 
							  withString:NSUserName() 
								 options:NSCaseInsensitiveSearch
								   range:NSMakeRange(0, [htmlCode length])];
	
	[[webView mainFrame] loadHTMLString:htmlCode 
								baseURL:Nil];
	[webView setPolicyDelegate:self];
	
	[htmlCode release];
}

- (void)webView:(WebView *)sender
decidePolicyForNavigationAction:(NSDictionary *)actionInformation
		request:(NSURLRequest *)request
		  frame:(WebFrame *)frame
decisionListener:(id<WebPolicyDecisionListener>)listener
{
	NSURL *url = [actionInformation objectForKey:WebActionOriginalURLKey];
	
	//Ignore file URLs, but open anything else
	if (![url isFileURL]) {
		[[NSWorkspace sharedWorkspace] openURL:url];
	}
	
	[listener ignore];
}

@end
