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

#import "MySQLSecurityCheck.h"

@interface MySQLSecurityCheck (PRIVAT)

- (void) setLocalizedTaskTitles:(NSArray*)anArray;

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
	NSMutableArray* taskTitels = [NSMutableArray array];
	
	if (skipNetworking)
		[taskTitels addObject:NSLocalizedString(@"DisableMySQLNetworking", @"Task description for the disable MySQL networking task")];
	
	if (setRootPassword)
		[taskTitels addObject:NSLocalizedString(@"SetMySQLRootPassword", @"Task description for the set mysql's root password task.")];
	
	if (setPMAPassword)
		[taskTitels addObject:NSLocalizedString(@"SetRandomMySQLPMAPassword", @"Taskdrscription for the set a random mysql's pma password task.")];
		
	[self setLocalizedTaskTitles:taskTitels];
}

- (NSArray*) localizedTaskTitles
{
	return localizedTaskTitles;
}

- (uint) tasks
{
	return [localizedTaskTitles count];
}

- (BOOL) doTask:(uint)task
{
	sleep(2);
	[[NSException exceptionWithName:@"blub" reason:@"blub2" userInfo:Nil] raise];
	return YES;
}

@end

@implementation MySQLSecurityCheck (PRIVAT)

- (void) setLocalizedTaskTitles:(NSArray*)anArray
{
	if ([anArray isEqualToArray:localizedTaskTitles])
		return;
	
	[localizedTaskTitles release];
	localizedTaskTitles = [anArray retain];
}

@end
