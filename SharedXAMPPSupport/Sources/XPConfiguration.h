/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

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

- (NSArray*) PHPVersions;
- (void) setPHPVersions:(NSArray*)anArray;
- (NSString*) activePHP;
- (void) setActivePHP:(NSString*)anString;
- (void) updatePHPVersions;

- (NSURL*) supportForumURL;
- (NSURL*) bugtrackerURL;

- (BOOL) hasFixRights;

@end
