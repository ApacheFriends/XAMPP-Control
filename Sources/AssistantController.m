//
//  AssistantController.m
//  XAMPP Control
//
//  Created by Christian Speich on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AssistantController.h"
#import "AssistantPage.h"
#import "AssistantStepIndicatorView.h"

#import <SharedXAMPPSupport/NSObject+Unproxy.h>

NSString *AssistantControllerContext = @"AssistantContollerContext";

@interface AssistantController (PRIVAT)

- (void) showPage:(AssistantPage*)anPage;

@end


@implementation AssistantController

- (id) init
{
	self = [super init];
	if (self != nil) {
		if (![NSBundle loadNibNamed:@"Assistant" owner:self]) {
			NSLog(@"failed");
			[self release];
			return Nil;
		}
	}
	return self;
}


- (void) awakeFromNib
{	
	[pagesController addObserver:self 
					  forKeyPath:@"selection" 
						 options:0 
						 context:AssistantControllerContext];
	NSLog(@"%@", stepIndicatorView);
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
	NSParameterAssert(anArray != Nil);
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
	NSParameterAssert(anString != Nil);
	
	if ([anString isEqualToString:title])
		return;
	
	[self willChangeValueForKey:@"title"];
	
	[title release];
	title = [anString retain];
	
	[self didChangeValueForKey:@"title"];
}

- (IBAction) forward:(id)sender
{	
	if (![pagesController canSelectNext])
		return [self close];
	
	if (![currentPage valid]) {
		NSBeep();
		return;
	}
	
	[pagesController selectNext:sender];
}

- (IBAction) back:(id)sender
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
		|| [currentPage type] == AssistantWorkPage
		|| [currentPage type] == AssistantFinishPage)
		[backButton setEnabled:NO];
	else
		[backButton setEnabled:YES];
	
	if ([currentPage isEqualTo:[pages lastObject]])
		[forwardButton setTitle:NSLocalizedString(@"Close", @"Close the Assistant (last page)")];
	else if ([currentPage type]  == AssistantSummaryPage)
		[forwardButton setTitle:NSLocalizedString(@"Execute", @"The summary has show now let the assistant execute the steps")];
	else
		[forwardButton setTitle:NSLocalizedString(@"Forward", @"Go forward")];
		
	if ([currentPage type] == AssistantWorkPage)
		[forwardButton setEnabled:NO];
	else
		[forwardButton setEnabled:YES];
	
	[stepIndicatorView selectStep:pageIndex];
}

@end
