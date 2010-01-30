/*
 
 XAMPP
 Copyright (C) 2009 by Apache Friends
 
 Authors of this file:
 - Christian Speich <kleinweby@apachefriends.org>
 
 This file is part of XAMPP.
 
 XAMPP is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 XAMPP is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with XAMPP.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#import "MySQLPlugIn.h"
#import "MySQLModule.h"
//#import "MySQLSecurityCheck.h"
#import "MySQLModuleViewController.h"

@implementation MySQLPlugIn

- (void) dealloc
{
	[self setModule:Nil];
	
	[super dealloc];
}


- (BOOL) setupError:(NSError**)anError
{
	NSMutableDictionary *dict;
	NSDictionary* bundleInformations;
	MySQLModule *module;
	XPModuleViewController *controller;
//	MySQLSecurityCheck* securityCheck;
	
	bundleInformations = [[NSBundle bundleForClass:[self class]] infoDictionary];
	dict = [NSMutableDictionary dictionary];
	module = [MySQLModule new];	
	controller = [[MySQLModuleViewController alloc] initWithModule:module];
	//securityCheck = [MySQLSecurityCheck new];
	
	[self setModule:module];
	
	[dict setValue:[NSArray arrayWithObject:module] forKey:XPModulesPlugInCategorie];
	
	if ([[bundleInformations objectForKey:@"RegisterControlsController"] boolValue])
		[dict setValue:[NSArray arrayWithObject:controller] forKey:XPControlsPlugInCategorie];
	
	//if ([[bundleInformations objectForKey:@"RegisterSecurityCheck"] boolValue])
	//	[dict setValue:[NSArray arrayWithObject:securityCheck] forKey:XPSecurityChecksPlugInCategorie];
	
	[module setShouldRunStartTests:[[bundleInformations objectForKey:@"RunStartTests"] boolValue]];
	
	[module release];
//	[securityCheck release];
	[controller release];
	
	[self setRegistryInfo:dict];
	
	return YES;
}

- (MySQLModule*) module
{
	return _module;
}

- (void) setModule:(MySQLModule*) module
{
	[_module release];
	_module = [module retain];
}

@end
