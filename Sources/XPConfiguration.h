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


@interface XPConfiguration : NSObject {
	NSString *version;
	NSArray	*PHPVersions;
	NSString *activePHP;
}

+ (id) sharedConfiguration;

+ (BOOL) isBetaVersion;
- (BOOL) isBetaVersion;

+ (NSString*) version;
- (NSString*) version;

+ (NSString*) fullXAMPPPathFor:(NSString*)anPath;
- (NSString*) fullXAMPPPathFor:(NSString*)anPath;
+ (NSString*) XAMPPPath;
- (NSString*) XAMPPPath;

- (NSArray*) PHPVersions;
- (void) setPHPVersions:(NSArray*)anArray;
- (NSString*) activePHP;
- (void) setActivePHP:(NSString*)anString;
- (void) updatePHPVersions;

- (NSURL*) supportForumURL;
- (NSURL*) bugtrackerURL;
- (NSURL*) installGuideURL;

- (BOOL) hasFixRights;

@end
