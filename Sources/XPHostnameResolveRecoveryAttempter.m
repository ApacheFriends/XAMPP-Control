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

#include <unistd.h>

#import "XPHostnameResolveRecoveryAttempter.h"
#import "XPModule.h"
#import "XPAlert.h"
#import "NSFileHandle+OpenAsRoot.h"

@implementation XPHostnameResolveRecoveryAttempter

- (id) initWithModule:(XPModule*)inModule;
{
	self = [super init];
	if (self != nil) {
		module = inModule;
	}
	return self;
}

- (BOOL)attemptRecoveryFromError:(NSError *)error 
					 optionIndex:(uint)recoveryOptionIndex
{
	if (recoveryOptionIndex == 0) {
		if (![self addHostnameToHosts])
			return NO;
		
		NSError* error = [module start];
		if (error) {
			[XPAlert presentError:error];
			return NO;
		}
	}
	
	return YES;
}

- (BOOL) addHostnameToHosts
{
	NSFileHandle* hosts = [NSFileHandle fileHandleWithRootPrivilegesForUpdatingAtPath:@"/etc/hosts"];
	char hostname[256];
	
	gethostname(hostname, 256);
	
	if (!hosts)
		return NO;
	
	[hosts seekToEndOfFile];
	[hosts writeData:[[NSString stringWithFormat:@"#Added by XAMPP Control\n127.0.0.1 %s\n\n", hostname] dataUsingEncoding:NSASCIIStringEncoding]];
	return YES;
}

@end
