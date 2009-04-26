//
//  SecurityCheckWelcomePage.m
//  XAMPP Control
//
//  Created by Christian Speich on 25.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecurityCheckWelcomePage.h"


@implementation SecurityCheckWelcomePage

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		if (![NSBundle loadNibNamed:@"SecurityCheckWelcomePage" owner:self]) {
			[self release];
			return Nil;
		}
		
		[self setTitle:NSLocalizedString(@"Welcome to the Security Check", @"The title of the Security Check welcome page")];
		[self setStepTitle:NSLocalizedString(@"Welcome", @"The step title of the Security Check welcome page which will displayed on the left side")];
		[self setType:AssistantNormalPage];
	}
	return self;
}

@end
