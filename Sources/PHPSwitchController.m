//
//  PHPSwitchController.m
//  XAMPP Control
//
//  Created by Christian Speich on 10.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PHPSwitchController.h"
#import "XPConfiguration.h"

@implementation PHPSwitchController

- (id) init
{
	self = [super init];
	if (self != nil) {
				
		if (![NSBundle loadNibNamed:@"PHPSwitchView" owner:self]) {
			[self release];
			return nil;
		}
		
		[[XPConfiguration sharedConfiguration] addObserver:self 
												forKeyPath:@"PHPVersions" 
												   options:Nil 
												   context:NULL];
		
		[[XPConfiguration sharedConfiguration] addObserver:self 
												forKeyPath:@"activePHP" 
												   options:Nil 
												   context:NULL];
		
		[self updateMenu];
	}
	return self;
}


- (NSView*) view
{
	return view;
}

- (void) updateMenu
{
	[phpMenu release];
	phpMenu = [[NSMenu alloc] init];
	
	NSArray *PHPVersions = [[XPConfiguration sharedConfiguration] PHPVersions];
	
	uint i, count = [PHPVersions count];
	for (i = 0; i < count; i++) {
		NSString * obj = [PHPVersions objectAtIndex:i];
		[phpMenu addItemWithTitle:obj 
						   action:NULL 
					keyEquivalent:@""];
	}
	
	phpIndex = [PHPVersions indexOfObject:[[XPConfiguration sharedConfiguration] activePHP]];
	
	[phpMenu addItem:[NSMenuItem separatorItem]];
	
	NSMenuItem *manage = [[NSMenuItem alloc] initWithTitle:@"Manage..."
													action:@selector(managePHPs:)
											 keyEquivalent:@""];
	
	[manage setTarget:self];
	
	[phpMenu addItem:manage];
	
	[manage release];
	
	[phpSelector setMenu:phpMenu];
	[phpSelector selectItemAtIndex:phpIndex];
}

- (void) managePHPs:(id)sender
{
	[phpSelector selectItemAtIndex:phpIndex];
}

- (IBAction) switchPHP:(id)sender
{
	NSLog(@"select %@", [sender titleOfSelectedItem]);
}

@end
