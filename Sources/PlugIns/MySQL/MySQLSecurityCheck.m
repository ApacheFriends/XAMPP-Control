//
//  MySQLSecurityCheck.m
//  XAMPP Control
//
//  Created by Christian Speich on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MySQLSecurityCheck.h"


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

@end
