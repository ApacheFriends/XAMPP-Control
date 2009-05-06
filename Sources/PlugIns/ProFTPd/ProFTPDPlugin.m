//
//  ProFTPdPlugin.m
//  XAMPP Control
//
//  Created by Christian Speich on 23.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProFTPDPlugin.h"
#import "ProFTPDModule.h"
#import "ProFTPDSecurityCheck.h"

#import <SharedXAMPPSupport/SharedXAMPPSupport.h>

@implementation ProFTPDPlugin

- (BOOL) setupError:(NSError**)anError
{
	NSMutableDictionary *dict;
	NSDictionary* bundleInformations;
	ProFTPDModule *module;
	XPModuleViewController *controller;
	ProFTPDSecurityCheck* securityCheck;
	
	bundleInformations = [[NSBundle bundleForClass:[self class]] infoDictionary];
	dict = [NSMutableDictionary dictionary];
	module = [ProFTPDModule new];
	controller = [[XPModuleViewController alloc] initWithModule:module];
	securityCheck = [ProFTPDSecurityCheck new];
	
	[dict setValue:[NSArray arrayWithObject:module] forKey:XPModulesPlugInCategorie];
	if ([[bundleInformations objectForKey:@"RegisterControlsController"] boolValue])
		[dict setValue:[NSArray arrayWithObject:controller] forKey:XPControlsPlugInCategorie];
	if ([[bundleInformations objectForKey:@"RegisterSecurityCheck"] boolValue])
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
