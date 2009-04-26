/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "XPConfiguration.h"
#include <unistd.h>

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

- (NSArray*) PHPVersions
{
	if (!PHPVersions)
		[self updatePHPVersions];
	
	return PHPVersions;
}

- (NSString*) activePHP
{
	if (!activePHP)
		[self updatePHPVersions];
	
	return activePHP;
}

- (void) updatePHPVersions
{
	NSArray *files;
	NSMutableArray *tmp;
	char buf[BUFSIZ];
	int rc = 0;
	
	files = [[NSFileManager defaultManager] directoryContentsAtPath:@"/Applications/XAMPP/xamppfiles/bin"];
	
	files = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF MATCHES 'php-[0-9].*'"]];
	
	tmp = [NSMutableArray array];
	
	int i, count = [files count];
	for (i = 0; i < count; i++) {
		NSString * obj = [files objectAtIndex:i];
		
		[tmp addObject:[obj substringFromIndex:4]];
	}
	
	[self setPHPVersions:tmp];
	
	rc = readlink("/Applications/XAMPP/xamppfiles/bin/php", buf, BUFSIZ);
	
	if (rc > 0) {
		buf[rc] = '\0';
		[self setActivePHP:[[[NSString stringWithUTF8String:buf] substringFromIndex:4] retain]];
	}
}

- (void) setActivePHP:(NSString*)anString
{
	if ([anString isEqualToString:activePHP])
		return;
	
	[self willChangeValueForKey:@"activePHP"];
	
	[activePHP release];
	activePHP = [anString retain];
	
	[self didChangeValueForKey:@"activePHP"];
}

- (void) setPHPVersions:(NSArray*)anArray
{
	if ([anArray isEqualToArray:PHPVersions])
		return;
	
	[self willChangeValueForKey:@"PHPVersions"];
	
	[PHPVersions release];
	PHPVersions = [anArray retain];
	
	[self didChangeValueForKey:@"PHPVersions"];
}

@end
