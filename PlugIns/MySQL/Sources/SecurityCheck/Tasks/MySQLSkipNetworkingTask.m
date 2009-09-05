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

#import <PlugIn/PlugIn.h>

#import "MySQLSkipNetworkingTask.h"
#import "MySQLPlugIn.h"
#import "MySQLModule.h"

@implementation MySQLSkipNetworkingTask

- (NSString*) localizedTitle
{
	return XPLocalizedString(@"DisableMySQLNetworking", 
							 @"Task description for the disable MySQL networking task");
}

- (BOOL) run
{
	MySQLPlugIn* plugIn;
	MySQLModule* module;
	XPRootTask* enableSkipNetworking;
	NSBundle* bundle;
	BOOL shouldStart = NO;
	BOOL success = YES;
	
	bundle = [NSBundle bundleForClass:[self class]];
	
	plugIn = [[[[PlugInManager sharedPlugInManager] plugInInformations]
			   objectForKey:[bundle bundleIdentifier]]
			  objectForKey:@"instance"];
	module = [plugIn module];
	
	if ([XPRootTask authorize])
		return NO;
	
	if ([module status] == XPRunning) {
		shouldStart = YES;
// TODO: Missing error check
		[module stop];
	}
	
	enableSkipNetworking = [XPRootTask new];
	
	[enableSkipNetworking setLaunchPath:[bundle pathForAuxiliaryExecutable:@"enableSkipNetworking.sh"]];
	
	[enableSkipNetworking launch];
	[enableSkipNetworking waitUntilExit];
	
	if ([enableSkipNetworking terminationStatus] != 0)
		success = NO;
	
	[enableSkipNetworking release];
	
	if (shouldStart) {
// TODO: Missing error check
		[module start];
	}
	
	return success;
}

@end
