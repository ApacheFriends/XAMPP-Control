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

#import "SecurityCheckSummaryPage.h"
#import "SecurityCheckProtocol.h"
#import "SecurityTaskProtocol.h"
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
		[self setTitle:XPLocalizedString(@"Summary", @"The title of the Security Check summary page")];
		[self setStepTitle:XPLocalizedString(@"Summary", @"The step title of the Security Check summary page which will displayed on the left side")];
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
	// Calculate all tasks
	[securityChecks makeObjectsPerformSelector:@selector(calcualteTasks)];
	
	// Well add the titels to the TasksView 
	NSEnumerator* enumerator = [securityChecks objectEnumerator];
	NSMutableArray* taskTitels = [NSMutableArray array];
	id<SecurityCheckProtocol> securityCheck;
	
	while ((securityCheck = [enumerator nextObject])) {
		NSEnumerator* tasksEnumerator = [[securityCheck tasks] objectEnumerator];
		id<SecurityTaskProtocol> task;
		
		while ((task = [tasksEnumerator nextObject])) {
			[taskTitels addObject:[task localizedTitle]];
		}
	}
	
	[tasksView setTaskTitels:taskTitels];
}

@end

