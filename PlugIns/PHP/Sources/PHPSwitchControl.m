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

#import "PHPSwitchControl.h"
#import "PHPManager.h"
#import "PHP.h"

@interface PHPSwitchControl(PRIVAT)

- (NSMenuItem*) managePHPsMenuItem;

@end


@implementation PHPSwitchControl

- (void) awakeFromNib
{
	[self updatePHPVersionsMenu];
	[statusIndicator setStatus:NoStatus];
}

- (void) updatePHPVersionsMenu
{
	NSMenu* menu = [NSMenu new];
	
	NSEnumerator* enumerator = [[[PHPManager sharedPHPManager] availablePHPs] objectEnumerator];
	PHP* php;
	
	while ((php = [enumerator nextObject])) {
		[menu addItemWithTitle:[php version] action:NULL keyEquivalent:@""];
	}
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	[menu addItem:[self managePHPsMenuItem]];
	
	[phpVersionSwitch setMenu:menu];
	
	[menu release];
}

#pragma mark -
#pragma mark Priority Protocol

- (int) priority
{
	return -900;
}

- (NSString*) comparisonString
{
	return @"PHPSwitch";
}

@end

@implementation PHPSwitchControl(PRIVAT)

- (NSMenuItem*) managePHPsMenuItem
{
	NSMenuItem* item;
	
	item = [[NSMenuItem alloc] initWithTitle:@"Manage PHP's..." action:@selector(managePHPs:) keyEquivalent:@""];
	
	[item setEnabled:NO];
	[item setTarget:self];
	
	return [item autorelease];
}

@end

