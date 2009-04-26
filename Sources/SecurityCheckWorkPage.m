//
//  SecurityCheckWorkPage.m
//  XAMPP Control
//
//  Created by Christian Speich on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecurityCheckWorkPage.h"


@implementation SecurityCheckWorkPage

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		if (![NSBundle loadNibNamed:@"SecurityCheckWorkPage" owner:self]) {
			[self release];
			return Nil;
		}
		
		[self setTitle:NSLocalizedString(@"Securing XAMPP...", @"The title of the Security Check work page")];
		[self setStepTitle:NSLocalizedString(@"Securing...", @"The step title of the Security Check work page which will displayed on the left side")];
		[self setType:AssistantWorkPage];
	}
	return self;
}

@end
