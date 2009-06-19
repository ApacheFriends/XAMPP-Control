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

#import <Cocoa/Cocoa.h>


@interface XPRootTask : NSObject {
	NSArray			*arguments;
	NSDictionary	*environment;
	NSString		*launchPath;
	NSFileHandle	*communicationsPipe;
	int				terminationStatus;
	pid_t			taskPid;
}

+ (NSError*) authorize;
- (NSError*) authorize;

- (NSArray*) arguments;
- (void) setArguments:(NSArray*) arguments;

- (NSDictionary*) environment;
- (void) setEnvironment:(NSDictionary*)enviroment;

- (NSString*) launchPath;
- (void) setLaunchPath:(NSString*)launchPath;

- (NSFileHandle*) communicationsPipe;

- (void) launch;
- (void) waitUntilExit;
- (bool) isRunning;
- (int)  terminationStatus;

@end
