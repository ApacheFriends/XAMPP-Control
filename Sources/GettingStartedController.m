/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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
