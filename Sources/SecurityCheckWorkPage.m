//
//  SecurityCheckWorkPage.m
//  XAMPP Control
//
//  Created by Christian Speich on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecurityCheckWorkPage.h"
#import "SecurityCheckProtocol.h"
#import "SecurityTasksView.h"

@implementation SecurityCheckWorkPage

- (id) initWithSecurityChecks:(NSArray*)anArray
{
	self = [super init];
	if (self != nil) {
		
		if (![NSBundle loadNibNamed:@"SecurityCheckWorkPage" owner:self]) {
			[self release];
			return Nil;
		}
		
		[self setSecurityChecks:anArray];
		[self setTitle:NSLocalizedString(@"Securing XAMPP...", @"The title of the Security Check work page")];
		[self setStepTitle:NSLocalizedString(@"Securing...", @"The step title of the Security Check work page which will displayed on the left side")];
		[self setType:AssistantWorkPage];
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

- (void) pageDidAppear
{
	[NSThread detachNewThreadSelector:@selector(work)
							 toTarget:self 
						   withObject:Nil];
}

- (void) work
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSEnumerator* enumerator = [securityChecks objectEnumerator];
	id<SecurityCheckProtocol,NSObject> securityCheck;
	uint currentTask = 0;
	
	while ((securityCheck = [enumerator nextObject])) {
		for (int i = 0; i < [securityCheck tasks]; i++) {
			[tasksView setStatus:SecurityTaskWorkingStatus forTask:currentTask];
			@try {
				if ([securityCheck doTask:i])
					[tasksView setStatus:SecurityTaskSuccessStatus forTask:currentTask];
				else
					[tasksView setStatus:SecurityTaskFailStatus forTask:currentTask];
			}
			@catch (NSException * e) {
				NSLog(@"Exception while [%@<%p> doTask:%i]: %@", NSStringFromClass([securityCheck class]), securityCheck, i, e);
				[tasksView setStatus:SecurityTaskFailStatus forTask:currentTask];
			}
			@finally {
				currentTask++;
			}
		}
	}
	
	[[self assistantController] performSelectorOnMainThread:@selector(forward:) withObject:self waitUntilDone:NO];
	
	[pool drain];
	[pool release];
}

@end
