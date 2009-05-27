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
