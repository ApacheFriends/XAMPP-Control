//
//  SecurityCheckSummaryPage.m
//  XAMPP Control
//
//  Created by Christian Speich on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecurityCheckSummaryPage.h"


@implementation SecurityCheckSummaryPage

- (id) init
{
	self = [super init];
	if (self != nil) {
		
		if (![NSBundle loadNibNamed:@"SecurityCheckSummaryPage" owner:self]) {
			[self release];
			return Nil;
		}
		
		[self setTitle:NSLocalizedString(@"Summary", @"The title of the Security Check summary page")];
		[self setStepTitle:NSLocalizedString(@"Summary", @"The step title of the Security Check summary page which will displayed on the left side")];
		[self setType:AssistantSummaryPage];
	}
	return self;
}

@end
