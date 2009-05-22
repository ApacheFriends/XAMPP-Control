//
//  MySQLSecurityCheck.m
//  XAMPP Control
//
//  Created by Christian Speich on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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
