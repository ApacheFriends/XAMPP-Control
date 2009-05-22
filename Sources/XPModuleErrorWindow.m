//
//  XPModuleErrorWindow.m
//  XAMPP Control
//
//  Created by Christian Speich on 06.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XPModuleErrorWindow.h"
#import "XPError.h"

#import <PlugIn/PlugIn.h>

@interface XPModuleErrorWindow (PRIVATE)

- (void) setupError;
- (void) setupLogView;
- (void) setupDescriptonAndTitle;

@end


@implementation XPModuleErrorWindow

+ (id) presentError:(NSError*)anError
{
	id window = [[self alloc] initWithError:anError];
	
	[window showWindow:anError];
	
	return window;
}

- (id) initWithError:(NSError*)anError
{
	self = [super init];
	if (self != nil) {
		
		if (![NSBundle loadNibNamed:@"ModuleErrorWindow" owner:self]) {
			[self release];
			return Nil;
		}
		
		error = [anError retain];
		
		[self setupError];
	}
	return self;
}

- (void) dealloc
{
	[error release];
	
	[super dealloc];
}


@end

@implementation XPModuleErrorWindow (PRIVATE)

- (void) setupError
{	
	[self setupDescriptonAndTitle];
	[self setupLogView];
}

- (void) setupDescriptonAndTitle
{
	NSString* title;
	
	switch ([error code]) {
		case XPDidNotStart:
			title = [NSString stringWithFormat:NSLocalizedString(@"%@ didn't start.", @"The Module %@ didn't start Title"), 
					 [[error userInfo] objectForKey:XPErrorModuleNameKey]];
			break;
		default:
			title = [NSString stringWithFormat:NSLocalizedString(@"Unknown error in %@", @"An unknown error happend in %@"), 
					 [[error userInfo] objectForKey:XPErrorModuleNameKey]];
			break;
	}
	
	[[self window] setTitle:title];
	[titleField setStringValue:title];
}

- (void) setupLogView
{
	NSMutableAttributedString* attributedContent;
	NSString* content;
	NSRange scrollRange;
	
	content = [[NSString alloc] initWithContentsOfFile:[[error userInfo] objectForKey:XPErrorLogFileKey]];
	
	if (!content)
		content = [NSString new];
	
	attributedContent = [[NSMutableAttributedString alloc] initWithString:content];
	
	[content release];
	
	PlugInInvokeHook(@"BeforeSetLogViewContent", [NSDictionary dictionaryWithObject:attributedContent forKey:@"content"]);
	
	scrollRange = NSMakeRange([attributedContent length], 0);
	
	[[logView textStorage] setAttributedString:attributedContent];
	[logView scrollRangeToVisible:scrollRange];
	
	[attributedContent release];
}

- (IBAction) ok:(id)sender
{
	[[self window] performClose:sender];
}

@end
