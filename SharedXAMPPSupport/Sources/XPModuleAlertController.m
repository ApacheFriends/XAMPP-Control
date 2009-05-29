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

#import "XPModuleAlertController.h"

@interface XPModuleAlertController(PRIVAT)

- (NSAlert*) alertForError:(NSError*)error;

- (void) setAlert:(NSAlert*)anAlert;
- (NSAlert*) alert;

@end


@implementation XPModuleAlertController

+ (void) presentError:(NSError*)anError
{
	XPModuleAlertController* controller = [[self alloc] initWithError:anError];
	
	[controller runModal];
	
	[controller release];
}

- (id) initWithError:(NSError*)anError
{
	self = [super init];
	if (self != nil) {
		[self setAlert:[self alertForError:anError]];
	}
	return self;
}

- (void) runModal
{
	[[self alert] runModal];
}

@end

@implementation XPModuleAlertController(PRIVAT)

- (void) setAlert:(NSAlert*)anAlert
{
	if ([anAlert isEqualTo:_alert])
		return;
	
	[_alert release];
	_alert = [anAlert retain];
}

- (NSAlert*) alert
{
	return _alert;
}

- (NSAlert*) alertForError:(NSError*)error
{
	NSAlert* alert;
	
	alert = [NSAlert alertWithError:error];
	
	[alert setAlertStyle:NSCriticalAlertStyle];
	
	return alert;
}

@end
