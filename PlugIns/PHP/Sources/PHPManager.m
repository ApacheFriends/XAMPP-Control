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

#import <XAMPP Control/XAMPP Control.h>

#import "PHPManager.h"
#import "PHP.h"

static id sharedManager = Nil;

@interface PHPManager (PRIVAT)

- (void) setAvailablePHPs:(NSArray*)array;
- (void) setActivePHP:(PHP*)php;
- (void) searchForPHPs;
- (void) determineActivePHP;

@end


@implementation PHPManager

#pragma mark -
#pragma mark SINGELTON

+ (id) allocWithZone:(NSZone*)aZone
{
	if (sharedManager == Nil)
		sharedManager = [super allocWithZone:aZone];
	return nil;
}

+ (id) sharedPHPManager
{
	if (sharedManager == Nil) {
		[self alloc];
		[sharedManager init];
	}
	
	return sharedManager;
}

- (int) retainCount
{
	return INT_MAX;
}

- (void) release
{	
}



#pragma mark -

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self searchForPHPs];
		[self determineActivePHP];
	}
	return self;
}


- (void) dealloc
{
	[self setAvailablePHPs:Nil];
	
	[super dealloc];
}


- (NSArray*) availablePHPs
{
	return _availablePHPs;
}

- (void) setAvailablePHPs:(NSArray*)array
{
	if ([array isEqualToArray:_availablePHPs])
		return;
	
	[self willChangeValueForKey:@"availablePHPs"];
	[_availablePHPs release];
	_availablePHPs = [array retain];
	[self didChangeValueForKey:@"availablePHPs"];
}

- (PHP*) activePHP
{
	return _activePHP;
}

- (void) setActivePHP:(PHP *)php
{
	if ([php isEqualTo:_activePHP])
		return;
	
	[self willChangeValueForKey:@"activePHP"];
	_activePHP = php;
	[self didChangeValueForKey:@"activePHP"];
}

- (PHP*) phpWithVersion:(NSString*)versionString
{
	NSArray* canidates;
	
	canidates = [[self availablePHPs] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"version like[cd] %@", versionString]];
	
	if ([canidates count] == 0)
		return Nil;
	else if ([canidates count] == 1)
		return [canidates objectAtIndex:0];
	else {
		NSLog(@"More than one PHP with the same Versions Number: %@", canidates);
		return [canidates objectAtIndex:0];
	}
}

- (void) searchForPHPs
{
	NSArray *files;
	NSMutableArray *tmp;
	
	files = [[NSFileManager defaultManager] directoryContentsAtPath:[XPConfiguration fullXAMPPPathFor:@"/xamppfiles/bin"]];

	files = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF MATCHES 'php-[0-9].*'"]];
	
	tmp = [NSMutableArray array];

	int i, count = [files count];
	for (i = 0; i < count; i++) {
		NSString * obj = [files objectAtIndex:i];
		PHP* php = [PHP new];

		[php setVersion:[obj substringFromIndex:4]];
		
		[tmp addObject:php];
		[php release];
	}
	
	[self setAvailablePHPs:tmp];
}

- (void) determineActivePHP
{
	NSString* activePHPVersion;
	
	activePHPVersion = [[NSFileManager defaultManager] 
						pathContentOfSymbolicLinkAtPath:[XPConfiguration fullXAMPPPathFor:@"xamppfiles/bin/php"]];
	// Remove the first 4 characters "php-"
	activePHPVersion = [activePHPVersion substringFromIndex:4];
	
	[self setActivePHP:[self phpWithVersion:activePHPVersion]];
}

@end
