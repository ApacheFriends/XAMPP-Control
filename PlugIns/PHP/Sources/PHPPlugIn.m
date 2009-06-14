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

#import "PHPPlugIn.h"
#import "PHPSwitchControl.h"
#import "PHPManager.h"

@implementation PHPPlugIn

- (BOOL) setupError:(NSError**)anError
{
	NSMutableDictionary *dict;
	dict = [NSMutableDictionary dictionary];
	
	PHPSwitchControl *viewController = [PHPSwitchControl new];
	
	if (![NSBundle loadNibNamed:@"PHPSwitchControl" owner:viewController]) {
		NSLog(@"Can not load PHPSwitchControl!!!");
		[viewController release];
		return NO;
	}
		
	[dict setValue:[NSArray arrayWithObject:viewController] forKey:XPControlsPlugInCategorie];
	
	[self setRegistryInfo:dict];
	[viewController release];
	
	PHPManager* manager = [PHPManager sharedPHPManager];
	
	NSLog(@"phps %@", [manager availablePHPs]);
	
	return YES;
}

@end
