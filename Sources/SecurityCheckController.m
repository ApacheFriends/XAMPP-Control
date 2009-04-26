//
//  SecrurityCheckController.m
//  XAMPP Control
//
//  Created by Christian Speich on 25.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecurityCheckController.h"

#import "SecurityCheckWelcomePage.h"
#import "SecurityCheckSummaryPage.h"
#import "SecurityCheckWorkPage.h"

#import <PlugIn/PlugIn.h>
#import <SharedXAMPPSupport/SharedXAMPPSupport.h>

@interface SecurityCheckController (PRIVATE)

- (void) setupPages;

@end


@implementation SecurityCheckController

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	[self setTitle:@"Security Check"];
	
	[self setupPages];
}

- (void) setupPages
{
	NSMutableArray* array = [NSMutableArray array];
	
	[array addObject:[[SecurityCheckWelcomePage new] autorelease]];
	
	[array addObjectsFromArray:[[[PlugInManager sharedPlugInManager] registry] objectsForCategorie:XPSecurityChecksPlugInCategorie]];
	
	[array addObject:[[SecurityCheckSummaryPage new] autorelease]];
	[array addObject:[[SecurityCheckWorkPage new] autorelease]];
	
	[self setPages:array];
}

@end
