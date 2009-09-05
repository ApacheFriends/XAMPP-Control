/*
 
 XAMPP
 Copyright (C) 2009 by Apache Friends
 
 Authors of this file:
 - Christian Speich <kleinweby@apachefriends.org>
 
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
#import "SecurityCheckConclusionPage.h"

#import <PlugIn/PlugIn.h>
#import <XAMPP Control/XAMPP Control.h>

@interface SecurityCheckController (PRIVATE)

- (BOOL) setupPages;

@end


@implementation SecurityCheckController

- (void) awakeFromNib
{
	[super awakeFromNib];
	
	[self setTitle:@"Security Check"];
}

- (void) prepareSecurityChecks {
	PlugInRegistry* plugInRegistry = [[PlugInManager sharedPlugInManager] registry];
	NSArray* all = [plugInRegistry objectsForCategorie:XPSecurityChecksPlugInCategorie];
	NSMutableArray* securityChecksFiltered = [NSMutableArray array];
	
	for (int i = 0; i < [all count]; i++) {
		id obj = [all objectAtIndex:i];
		if ([obj conformsToProtocol:@protocol(SecurityCheckProtocol)] &&
			[obj conformsToProtocol:@protocol(NSCopying)]) {
			/* Make a copy here so we have a fresh securitycheck every-
			 time we open this assistant */
			obj = [obj copy];
			[securityChecksFiltered addObject:obj];
			[obj checkSecurity];
			[obj release];
		}
		else {
			DLog(@"%@ does not conforms to the SecurityCheckProtocol or NSCopying Protocol.!", obj);
		}
	}
	
	[securityChecks release];
	securityChecks = [securityChecksFiltered retain];
}

- (void) prepareSecurityCheckPages {
	NSPredicate *predicate;
	
	predicate = [NSPredicate predicateWithFormat:@"isSecure == NO"];
	
	[securityCheckPages release];
	securityCheckPages = [[securityChecks filteredArrayUsingPredicate:predicate] retain];
}

- (BOOL) setupPages
{
	NSMutableArray* array;
	
	array = [NSMutableArray array];
	
	[self prepareSecurityChecks];
	[self prepareSecurityCheckPages];
	
	/* There are no security checks to display, this assistant is useless
	   display a message to the user and returns bool here to avoid the display
	   of the assistant window. */
	if ([securityChecks count] == 0) {
		NSRunAlertPanel(XPLocalizedString(@"NoSecurityCheksTitle", @"Titel for the modal alert panel which is shown when no valid securitychecks are registered."), 
						XPLocalizedString(@"NoSecurityChecksDescription", @"Description for the modal altert panel which is shown when no valid securitychecks are registered."), 
						XPLocalizedString(@"OK", @"Titel for the OK-Button of an modal alert panel"), 
						Nil, Nil);
		return NO;
	}
	
	[array addObject:[[SecurityCheckWelcomePage new] autorelease]];
	
	[array addObjectsFromArray:securityCheckPages];
	
	[array addObject:[[[SecurityCheckSummaryPage alloc] initWithSecurityChecks:securityChecks] autorelease]];
	[array addObject:[[[SecurityCheckWorkPage alloc] initWithSecurityChecks:securityChecks] autorelease]];
	[array addObject:[[SecurityCheckConclusionPage new] autorelease]];
	
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
