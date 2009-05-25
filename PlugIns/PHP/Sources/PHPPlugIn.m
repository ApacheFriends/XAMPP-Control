//
//  PHPPlugin.m
//  XAMPP Control
//
//  Created by Christian Speich on 16.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PHPPlugIn.h"
#import "PHPSwitchControl.h"

@implementation PHPPlugIn

- (BOOL) setupError:(NSError**)anError
{
	NSMutableDictionary *dict;
	dict = [NSMutableDictionary dictionary];
	
	PHPSwitchControl *viewController = [PHPSwitchControl new];
	
	if (![NSBundle loadNibNamed:@"PHPSwitchControl" owner:viewController]) {
		NSLog(@"Can not load PHPSwitchControl!!!");
		return NO;
	}
		
	[dict setValue:[NSArray arrayWithObject:viewController] forKey:XPControlsPlugInCategorie];
	
	[self setRegistryInfo:dict];
	
	return YES;
}

@end
