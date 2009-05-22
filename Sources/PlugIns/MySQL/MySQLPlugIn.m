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
	NSDictionary* bundleInformations;
	MySQLModule *module;
	XPModuleViewController *controller;
	MySQLSecurityCheck* securityCheck;
	
	bundleInformations = [[NSBundle bundleForClass:[self class]] infoDictionary];
	dict = [NSMutableDictionary dictionary];
	module = [MySQLModule new];
	controller = [[XPModuleViewController alloc] initWithModule:module];
	securityCheck = [MySQLSecurityCheck new];
	
	[dict setValue:[NSArray arrayWithObject:module] forKey:XPModulesPlugInCategorie];
	if ([[bundleInformations objectForKey:@"RegisterControlsController"] boolValue])
		[dict setValue:[NSArray arrayWithObject:controller] forKey:XPControlsPlugInCategorie];
	if ([[bundleInformations objectForKey:@"RegisterSecurityCheck"] boolValue])
		[dict setValue:[NSArray arrayWithObject:securityCheck] forKey:XPSecurityChecksPlugInCategorie];
	
	[module release];
	[controller release];
	
	[self setRegistryInfo:dict];
	
	return YES;
}

@end
