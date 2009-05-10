//
//  SecurityCheckSummaryPage.h
//  XAMPP Control
//
//  Created by Christian Speich on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <SharedXAMPPSupport/AssistantPage.h>

@interface SecurityCheckSummaryPage : AssistantPage {
	NSArray* securityChecks;
}

- (id) initWithSecurityChecks:(NSArray*)anArray;

- (void) setSecurityChecks:(NSArray*)anArray;
- (NSArray*)securityChecks;

@end
