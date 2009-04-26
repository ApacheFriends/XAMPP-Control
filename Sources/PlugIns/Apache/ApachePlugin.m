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
	ApacheModule *module;
	XPModuleViewController *controller;
	
	dict = [NSMutableDictionary dictionary];
	module = [ApacheModule new];
	controller = [[XPModuleViewController alloc] initWithModule:module];
	
	[dict setValue:[NSArray arrayWithObject:module] forKey:XPModulesPlugInCategorie];
	[dict setValue:[NSArray arrayWithObject:controller] forKey:XPControlsPlugInCategorie];
	
	[module release];
	[controller release];
	
	registryInfo = [dict retain];

	return YES;
}

- (void) dealloc
{
	[registryInfo release];
	[super dealloc];
}

- (NSDictionary*) registryInfo
{
	return registryInfo;
}

@end
