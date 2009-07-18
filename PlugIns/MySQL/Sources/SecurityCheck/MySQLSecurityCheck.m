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

#import "MySQLSecurityCheck.h"

#import "MySQLSkipNetworkingTask.h"
#import "MySQLRootPasswordTask.h"
#import "MySQLRandomPMAPasswordTask.h"

@interface MySQLSecurityCheck (PRIVAT)

- (void) setTasks:(NSArray*)anArray;

@end


@implementation MySQLSecurityCheck

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		if (![NSBundle loadNibNamed:@"MySQLSecurityCheck" owner:self]) {
			[self release];
			return Nil;
		}
		
		[self setTitle:NSLocalizedString(@"Secure MySQL", @"The title of the Security Check MySQL page")];
		[self setStepTitle:NSLocalizedString(@"MySQL", @"The step title of the Security Check MySQL page which will displayed on the left side")];
		[self setType:AssistantNormalPage];
	}
	return self;
}

- (void) dealloc
{
	[self setTasks:Nil];
	
	[super dealloc];
}


- (BOOL) valid
{
	if (setRootPassword) {	
		if ([[password stringValue] length] < 6)
			return NO;
		
		if (![[password stringValue] isEqualToString:[passwordConfirm stringValue]])
			return NO;
	}
	
	return YES;
}

- (void) calcualteTasks
{
	NSMutableArray* tasks = [NSMutableArray array];
	
	if (skipNetworking)
		[tasks addObject:[[MySQLSkipNetworkingTask new] autorelease]];
	
	if (setRootPassword) {
		MySQLRootPasswordTask* task = [MySQLRootPasswordTask new];
		
		[task setPassword:[password stringValue]];
		[tasks addObject:task];
		[task release];
	}
	
	if (setRootPassword)
		[tasks addObject:NSLocalizedString(@"SetMySQLRootPassword", @"Task description for the set mysql's root password task.")];
	
	if (setPMAPassword)
		[tasks addObject:[[MySQLRandomPMAPasswordTask new] autorelease]];
	
	[self setTasks:tasks];
}

- (NSArray*) tasks
{
	return _tasks;
}

@end

@implementation MySQLSecurityCheck (PRIVAT)

- (void) setTasks:(NSArray*)anArray
{
	if ([anArray isEqualToArray:_tasks])
		return;
	
	[_tasks release];
	_tasks = [anArray retain];
}

@end
