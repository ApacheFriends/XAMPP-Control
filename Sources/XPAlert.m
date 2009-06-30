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

#import "XPAlert.h"


@implementation XPAlert

+ (void) presentError:(NSError*)anError
{
// TODO: !!!!
	[NSApp presentError:anError];
	return;
	
	XPAlert* controller = [[self alloc] initWithError:anError];
	
	[controller runModal];
	
	[controller release];
}

- (id) initWithError:(NSError*)anError
{
	self = [super init];
	if (self != nil) {
		
		[self release];
		
		if ([[anError domain] isEqualToString:NSCocoaErrorDomain]
			&& [anError code] == NSUserCancelledError) {
			self = Nil;
		} else {
			NSAlert* alert;
			alert = [NSAlert alertWithError:anError];
			[alert setAlertStyle:NSCriticalAlertStyle];
			self = [alert retain];
		}
	}
	return self;
}

- (void) runModal
{
	
}

@end
