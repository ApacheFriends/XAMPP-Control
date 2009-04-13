/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "XPConfiguration.h"

static id sharedConfiguration = Nil;

@implementation XPConfiguration

#pragma mark -
#pragma mark SINGELTON

+ (id) allocWithZone:(NSZone*)aZone
{
	if (sharedConfiguration == Nil)
		sharedConfiguration = [super allocWithZone:aZone];
	return nil;
}

+ (id) sharedConfiguration
{
	if (sharedConfiguration == Nil)
		[self alloc];
	
	return sharedConfiguration;
}

- (int) retainCount
{
	return INT_MAX;
}

- (void) release
{	
}

#pragma mark -
#pragma mark Proptertys

+ (BOOL) isBetaVersion
{
	return [[self sharedConfiguration] isBetaVersion];
}

- (BOOL) isBetaVersion
{
	char isBeta = [[[[NSBundle mainBundle] infoDictionary] valueForKey:@"isBeta"] characterAtIndex:0];
	if (isBeta == 'Y'
		|| isBeta == 'y' 
		|| isBeta == 'T'
		|| isBeta == 't')
		return YES;
	return NO;
}

+ (NSString*) version
{
	return [[self sharedConfiguration] version];
}

- (NSString*) version
{
	if (!version) {
		version = [NSString stringWithContentsOfFile:@"/Applications/XAMPP/xamppfiles/lib/VERSION"];
		version = [version stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		[version retain];
		
		if (!version)
			version = @"Unknown";
	}
	
	return version;
}

- (NSURL*) supportForumURL
{
	return [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"SupportForumURL"]];
}

- (NSURL*) bugtrackerURL
{
	return [NSURL URLWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"BugtrackerURL"]];
}

- (BOOL) hasFixRights
{
	return [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/XAMPP/etc/xampp/fix_rights"];
}

@end
