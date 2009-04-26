//
//  MySQLPlugIn.m
//  XAMPP Control
//
//  Created by Christian Speich on 23.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MySQLPlugIn.h"
#import "MySQLModule.h"
#import "MySQLSecurityCheck.h"

#import <SharedXAMPPSupport/SharedXAMPPSupport.h>

@implementation MySQLPlugIn

- (BOOL) setupError:(NSError**)anError
{
	NSMutableDictionary *dict;
	MySQLModule *module;
	XPModuleViewController *controller;
	MySQLSecurityCheck* securityCheck;
	
	dict = [NSMutableDictionary dictionary];
	module = [MySQLModule new];
	controller = [[XPModuleViewController alloc] initWithModule:module];
	securityCheck = [MySQLSecurityCheck new];
	
	[dict setValue:[NSArray arrayWithObject:module] forKey:XPModulesPlugInCategorie];
	[dict setValue:[NSArray arrayWithObject:controller] forKey:XPControlsPlugInCategorie];
	[dict setValue:[NSArray arrayWithObject:securityCheck] forKey:XPSecurityChecksPlugInCategorie];
	
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
