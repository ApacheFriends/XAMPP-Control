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

#import "PHP.h"
#import "PHPManager.h"

@implementation PHP

- (void) dealloc
{
	[self setVersion:Nil];
	
	[super dealloc];
}


- (NSString*) version
{
	return _version;
}

- (void) setVersion:(NSString*)string
{
	if ([string isEqualToString:_version])
		return;
	
	[_version release];
	_version = [string retain];
}

- (BOOL) isActive
{
	return [self isEqual:[[PHPManager sharedPHPManager] activePHP]];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@(%p) %@>", [self className], self, [self version]];
}

@end
