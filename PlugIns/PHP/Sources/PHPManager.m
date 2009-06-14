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

#import <XAMPP Control/XAMPP Control.h>

#import "PHPManager.h"
#import "PHP.h"

static id sharedManager = Nil;

@interface PHPManager (PRIVAT)

- (void) setAvailablePHPs:(NSArray*)array;
- (void) searchForPHPs;

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
	
	[_availablePHPs release];
	_availablePHPs = [array retain];
}

- (PHP*) activePHP
{
	return _activePHP;
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

@end
