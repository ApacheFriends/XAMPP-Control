//
//  SecurityCheckConclusionPage.m
//  XAMPP Control
//
//  Created by Christian Speich on 05.09.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecurityCheckConclusionPage.h"


@implementation SecurityCheckConclusionPage

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		if (![NSBundle loadNibNamed:@"SecurityCheckConclusionPage" owner:self]) {
			[self release];
			return Nil;
		}
		
		[self setTitle:XPLocalizedString(@"Conclusion...", @"The title of the Security Check Conclusion page")];
		[self setStepTitle:XPLocalizedString(@"Conclusion...", @"The step title of the Security Check Conclusion page which will displayed on the left side")];
		[self setType:AssistantConclusionPage];
	}
	return self;
}

@end
