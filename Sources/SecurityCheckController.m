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

#import "SecurityCheckController.h"

#import "SecurityCheckWelcomePage.h"
#import "SecurityCheckSummaryPage.h"
#import "SecurityCheckWorkPage.h"
#import "SecurityCheckProtocol.h"

#import <PlugIn/PlugIn.h>
#import <XAMPP Control/SharedXAMPPSupport.h>

@interface SecurityCheckController (PRIVATE)

- (BOOL) setupPages;

@end


@implementation SecurityCheckController

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	[self setTitle:@"Security Check"];
}

- (NSMutableArray *) mutableSecurityChecksArray {
	PlugInRegistry* plugInRegistry = [[PlugInManager sharedPlugInManager] registry];
	NSMutableArray* securityChecks = [[plugInRegistry objectsForCategorie:XPSecurityChecksPlugInCategorie] mutableCopy];
	
	/* Go thorugh our array of securitychecks and check if it confroms to the securitycheckprotocol.
	   If not, we remove it from the array and decrement i to not exceed the array bounds.
	 
	   TODO: Maybe this can be done with an predicate? */
	
	for (int i = 0; i < [securityChecks count]; i++) {
		id obj = [securityChecks objectAtIndex:i];
		if (![obj conformsToProtocol:@protocol(SecurityCheckProtocol)]) {
			NSLog(@"%@ does not conforms to the SecurityCheckProtocol!", obj);
			[securityChecks removeObjectAtIndex:i];
			i--;
		}
	}
	
	return [securityChecks autorelease];
}

- (BOOL) setupPages
{
	NSMutableArray* array;
	NSMutableArray *securityChecks;
	
	securityChecks = [self mutableSecurityChecksArray];
	array = [NSMutableArray array];
	
	/* There are no security checks to display, this assistant is useless
	   display a message to the user and returns bool here to avoid the display
	   of the assistant window. */
	if ([securityChecks count] == 0) {
		NSRunAlertPanel(NSLocalizedString(@"NoSecurityCheksTitle", @"Titel for the modal alert panel which is shown when no valid securitychecks are registered."), 
						NSLocalizedString(@"NoSecurityChecksDescription", @"Description for the modal altert panel which is shown when no valid securitychecks are registered."), 
						NSLocalizedString(@"OK", @"Titel for the OK-Button of an modal alert panel"), 
						Nil, Nil);
		return NO;
	}
	
	[array addObject:[[SecurityCheckWelcomePage new] autorelease]];
	
	[array addObjectsFromArray:securityChecks];
	
	[array addObject:[[[SecurityCheckSummaryPage alloc] initWithSecurityChecks:securityChecks] autorelease]];
	[array addObject:[[[SecurityCheckWorkPage alloc] initWithSecurityChecks:securityChecks] autorelease]];
	
	[self setPages:array];
	
	return YES;
}

- (IBAction) showWindow:(id)sender
{
	if (![self setupPages])
		return;
	
	[super showWindow:sender];
}

@end
