//
//  PHPSwitchControl.m
//  XAMPP Control
//
//  Created by Christian Speich on 16.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PHPSwitchControl.h"

@interface PHPSwitchControl(PRIVAT)

- (NSMenuItem*) managePHPsMenuItem;

@end


@implementation PHPSwitchControl

- (void) awakeFromNib
{
	[self updatePHPVersionsMenu];
}

- (void) updatePHPVersionsMenu
{
	NSMenu* menu = [NSMenu new];
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	[menu addItem:[self managePHPsMenuItem]];
	
	[phpVersionSwitch setMenu:menu];
}

#pragma mark -
#pragma mark Priority Protocol

- (int) priority
{
	return -900;
}

- (NSString*) comparisonString
{
	return @"PHPSwitch";
}

@end

@implementation PHPSwitchControl(PRIVAT)

- (NSMenuItem*) managePHPsMenuItem
{
	NSMenuItem* item;
	
	item = [[NSMenuItem alloc] initWithTitle:@"Manage PHP's..." action:@selector(managePHPs:) keyEquivalent:@""];
	
	[item setEnabled:NO];
	[item setTarget:self];
	
	return [item autorelease];
}

@end

