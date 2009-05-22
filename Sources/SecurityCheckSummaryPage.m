//
//  SecurityCheckSummaryPage.m
//  XAMPP Control
//
//  Created by Christian Speich on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecurityCheckSummaryPage.h"
#import "SecurityCheckProtocol.h"
#import "SecurityTasksView.h"

@implementation SecurityCheckSummaryPage

- (id) initWithSecurityChecks:(NSArray*)anArray
{
	self = [super init];
	if (self != nil) {
		
		if (![NSBundle loadNibNamed:@"SecurityCheckSummaryPage" owner:self]) {
			[self release];
			return Nil;
		}
		
		[self setSecurityChecks:anArray];
		[self setTitle:NSLocalizedString(@"Summary", @"The title of the Security Check summary page")];
		[self setStepTitle:NSLocalizedString(@"Summary", @"The step title of the Security Check summary page which will displayed on the left side")];
		[self setType:AssistantSummaryPage];
	}
	return self;
}

- (void) dealloc
{
	[self setSecurityChecks:Nil];
	[super dealloc];
}


#pragma mark -
#pragma mark Getter and Setter

- (void) setSecurityChecks:(NSArray*)anArray
{
	if ([anArray isEqualToArray:securityChecks])
		return;
	
	[securityChecks release];
	securityChecks = [anArray retain];
}

- (NSArray*)securityChecks
{
	return securityChecks;
}

#pragma mark -
#pragma mark Tasks

- (void) pageWillAppear
{
	/*
	  First calulate all tasks, thenn add them to our tasksArray
	 */
	
	NSEnumerator* enumerator = [securityChecks objectEnumerator];
	NSMutableArray* tasks = [NSMutableArray array];
	id<SecurityCheckProtocol> securityCheck;
	
	while ((securityCheck = [enumerator nextObject])) {
		[securityCheck calcualteTasks];
		
		[tasks addObjectsFromArray:[securityCheck localizedTaskTitles]];
	}
	
	[tasksView setTasks:tasks];
}

@end

