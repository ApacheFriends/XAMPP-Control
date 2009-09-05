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

#import "AssistantController.h"
#import "AssistantPage.h"
#import "AssistantStepIndicatorView.h"

#import <XAMPP Control/NSObject+Additions.h>

NSString *AssistantControllerContext = @"AssistantContollerContext";

@interface AssistantController (PRIVAT)

- (void) showPage:(AssistantPage*)anPage;

@end


@implementation AssistantController

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self loadWindow];
		[[self window] setDelegate:self];
	}
	return self;
}

- (NSString *)windowNibName
{
	return @"Assistant";
}

- (void) dealloc
{
	[self setTitle:Nil];
	[self setPages:Nil];
	
	[super dealloc];
}


- (void) awakeFromNib
{	
	[pagesController addObserver:self 
					  forKeyPath:@"selection" 
						 options:0 
						 context:AssistantControllerContext];
}

- (IBAction) showWindow:(id)sender
{
	[super showWindow:sender];
	[self showPage:[pages objectAtIndex:0]];
}

- (NSArray*)pages
{
	return pages;
}

- (void)setPages:(NSArray*)anArray
{
	NSEnumerator* enumerator;
	AssistantPage* page;
	NSMutableArray* steps;
	
	if ([anArray isEqualToArray:pages])
		return;
	
	[self willChangeValueForKey:@"pages"];
	
	[pages release];
	pages = [anArray retain];
	
	enumerator = [pages objectEnumerator];
	steps = [NSMutableArray array];
	
	while ((page = [enumerator nextObject])) {
		[page setAssistantController:self];
		[steps addObject:[page stepTitle]];
	}

	[stepIndicatorView setSteps:steps];
	
	[self didChangeValueForKey:@"pages"];
}

- (NSString*) title
{
	return title;
}

- (void) setTitle:(NSString*)anString
{	
	if ([anString isEqualToString:title])
		return;
	
	[self willChangeValueForKey:@"title"];
	
	[title release];
	title = [anString retain];
	
	[self didChangeValueForKey:@"title"];
}

- (IBAction) continue:(id)sender
{	
	if (![pagesController canSelectNext])
		return [self close];
	
	if (![currentPage isValid]) {
		NSBeep();
		return;
	}
	
	[pagesController selectNext:sender];
}

- (IBAction) goBack:(id)sender
{
	[pagesController selectPrevious:sender];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context != AssistantControllerContext)
		return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	
	if (object == pagesController
		&& [keyPath isEqualToString:@"selection"])
		[self showPage:[[pagesController selection] unproxy]];
	
}

- (void) showPage:(AssistantPage*)anPage
{
	int pageIndex;
	
	if ([anPage isEqualTo:currentPage])
		return;
	
	[currentPage pageWillDisappear];
	[[currentPage view] removeFromSuperview];
	[currentPage pageDidDisappear];
	[currentPage release];
	
	currentPage = [anPage retain];
	[currentPage pageWillAppear];
	[pageView addSubview:[currentPage view]];
	[currentPage pageDidAppear];

	pageIndex = [pages indexOfObject:currentPage];
	
	if (pageIndex == 0
		|| [currentPage type] == AssistantWorkingkPage
		|| [currentPage type] == AssistantConclusionPage)
		[backButton setEnabled:NO];
	else
		[backButton setEnabled:YES];
	
	if ([currentPage isEqualTo:[pages lastObject]])
		[forwardButton setTitle:NSLocalizedString(@"Done", @"Done the Assistant (last page)")];
	else if ([currentPage type]  == AssistantSummaryPage)
		[forwardButton setTitle:NSLocalizedString(@"Do it!", @"The summary has show now let the assistant execute the steps")];
	else
		[forwardButton setTitle:NSLocalizedString(@"Continue", @"Continue the assistant")];
		
	if ([currentPage type] == AssistantWorkingkPage)
		[forwardButton setEnabled:NO];
	else
		[forwardButton setEnabled:YES];
	
	[stepIndicatorView selectStep:pageIndex];
}
	
- (BOOL)windowShouldClose:(id)sender
{
	return [currentPage type] != AssistantWorkingkPage;
}

@end
