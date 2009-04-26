//
//  ProFTPDSecurityCheck.m
//  XAMPP Control
//
//  Created by Christian Speich on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProFTPDSecurityCheck.h"


@implementation ProFTPDSecurityCheck

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		if (![NSBundle loadNibNamed:@"ProFTPDSecurityCheck" owner:self]) {
			[self release];
			return Nil;
		}
		
		[self setTitle:NSLocalizedString(@"Secure ProFTPD", @"The title of the Security Check ProFTPD page")];
		[self setStepTitle:NSLocalizedString(@"ProFTPD", @"The step title of the Security Check ProFTPD page which will displayed on the left side")];
		[self setType:AssistantNormalPage];
	}
	return self;
}

- (BOOL) valid
{
	if (changeNobodyPassword) {	
		if ([[password stringValue] length] < 6)
			return NO;
	
		if (![[password stringValue] isEqualToString:[passwordConfirm stringValue]])
			return NO;
	}
	
	return YES;
}

@end
