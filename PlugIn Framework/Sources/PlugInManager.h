//
//  PlugInManager.h
//  XAMPP Control
//
//  Created by Christian Speich on 20.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PlugInRegistry;

extern NSString* PlugInErrorDomain;

enum {
	PlugInNotFound = 1,
	PlugInNotLoaded = 2,
	PlugInNotRegisterd = 3,
	PlugInNotCompatible = 4
};

#define PlugInInvokeHook(hookName,dictionary) [[[PlugInManager sharedPlugInManager] registry] invokeHook:(hookName) withDictionary:(dictionary)]

@interface PlugInManager : NSObject {
	NSMutableArray* searchPaths;
	NSMutableArray* loadedPlugins;
	PlugInRegistry* registry;
}

+ (PlugInManager*)sharedPlugInManager;

- (NSArray*) searchPaths;

- (bool) loadPlugIn:(NSString*)anPath error:(NSError**)anError;
- (bool) loadPlugInNamed:(NSString*)plugInName error:(NSError**)anError;
- (bool) loadAllPluginsError:(NSError**)anError;

- (NSArray*) loadedPlugins;
- (PlugInRegistry*) registry;

@end
