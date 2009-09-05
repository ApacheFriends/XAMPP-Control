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

#import "SecurityCheckWorkPage.h"
#import "SecurityCheckProtocol.h"
#import "SecurityTaskProtocol.h"
#import "SecurityTasksView.h"
#import "NSObject+Additions.h"

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
		[self setType:AssistantWorkingkPage];
		[tasksView setCenterVertically:YES];
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

- (NSArray*) tasks
{
	return _tasks;
}

- (void) setTasks:(NSArray*)anArray
{
	if ([anArray isEqualToArray:_tasks])
		return;
	
	[_tasks release];
	_tasks = [anArray retain];
}

#pragma mark -
#pragma mark Tasks

- (void) pageWillAppear
{
	// Well add the titels to the TasksView 
	NSEnumerator* enumerator = [securityChecks objectEnumerator];
	NSMutableArray* taskTitels = [NSMutableArray array];
	NSMutableArray* tasks = [NSMutableArray array];
	id<SecurityCheckProtocol> securityCheck;
	
	while ((securityCheck = [enumerator nextObject])) {
		NSEnumerator* tasksEnumerator = [[securityCheck tasks] objectEnumerator];
		id<SecurityTaskProtocol> task;
		
		while ((task = [tasksEnumerator nextObject])) {
			[taskTitels addObject:[task localizedTitle]];
		}
		
		[tasks addObjectsFromArray:[securityCheck tasks]];
	}
	
	[tasksView setTaskTitels:taskTitels];
	[self setTasks:tasks];
}

- (void) pageDidAppear
{
	[NSThread detachNewThreadSelector:@selector(work)
							 toTarget:self 
						   withObject:Nil];
}

- (void) work
{
	NSAutoreleasePool* pool = [NSAutoreleasePool new];
	NSEnumerator* enumerator = [[self tasks] objectEnumerator];
	id<SecurityTaskProtocol,NSObject> task;
	uint currentTask = 0;
	
	while ((task = [enumerator nextObject])) {
		NSLog(@"%@", task);
		[tasksView setStatus:SecurityTaskWorkingStatus forTask:currentTask];
		@try {
			if ([task run])
				[tasksView setStatus:SecurityTaskSuccessStatus forTask:currentTask];
			else
				[tasksView setStatus:SecurityTaskFailStatus forTask:currentTask];
		}
		@catch (NSException * e) {
			NSLog(@"Exception while [%@<%p> run]: %@", NSStringFromClass([task class]), task, e);
			[tasksView setStatus:SecurityTaskFailStatus forTask:currentTask];
		}
		@finally {
			currentTask++;
		}
	}
	
	/* Wait one second and then go to the next page */
	
	[[[self assistantController] mainThreadProxy] performSelector:@selector(continue:) 
													   withObject:self 
													   afterDelay:1.0];
	
	[pool release];
}

@end
