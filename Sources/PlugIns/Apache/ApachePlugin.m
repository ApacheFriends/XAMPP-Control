//
//  ApachePlugin.m
//  XAMPP Control
//
//  Created by Christian Speich on 23.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ApachePlugin.h"
#import "ApacheModule.h"

#import <SharedXAMPPSupport/SharedXAMPPSupport.h>

@implementation ApachePlugin

- (BOOL) setupError:(NSError**)anError
{
	NSMutableDictionary *dict;
	NSDictionary* bundleInformations;
	ApacheModule *module;
	XPModuleViewController *controller;
	
	bundleInformations = [[NSBundle bundleForClass:[self class]] infoDictionary];
	dict = [NSMutableDictionary dictionary];
	module = [ApacheModule new];
	controller = [[XPModuleViewController alloc] initWithModule:module];
	
	[dict setValue:[NSArray arrayWithObject:module] forKey:XPModulesPlugInCategorie];
	if ([[bundleInformations objectForKey:@"RegisterControlsController"] boolValue])
		[dict setValue:[NSArray arrayWithObject:controller] forKey:XPControlsPlugInCategorie];
	
	[module release];
	[controller release];
	
	[self setRegistryInfo:dict];

	return YES;
}

@end
