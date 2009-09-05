/*
 
 The PlugIn Framework
 Copyright (C) 2009 by Christian Speich <kleinweby@kleinweby.de>
 
 This file is part of the PlugIn Framework.
 
 The PlugIn Framework is free software: you can redistribute it and/or modify
 it under the terms of the GNU Lesser General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 The PlugIn Framework is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public License
 along with the PlugIn Framework.  If not, see <http://www.gnu.org/licenses/>.
 
 */

#import <Foundation/Foundation.h>

@class PlugInRegistry;

extern NSString* PlugInErrorDomain;

#define kCollectedErrorsKey (@"CollectedErrors")

enum _PlugInError {
	PlugInNotFound = 1,
	PlugInNotLoaded,
	PlugInNotRegistered,
	PlugInNotCompatible,
	PlugInNotAllLoaded
};

typedef enum _PlugInError PlugInError;

void PlugInInvokeHook(NSString* hookName, id object);

@interface PlugInManager : NSObject {
	NSMutableArray* searchPaths;
	NSMutableDictionary* plugInInformations;
	
	PlugInRegistry* registry;
	Class			plugInSuperclass;
	
	NSString*		plugInExtension;
}

+ (PlugInManager*)sharedPlugInManager;

- (Class) plugInSuperclass;
- (void) setPlugInSuperclass:(Class)anClass;

- (NSArray*) searchPaths;
- (void) setSearchPaths:(NSArray*)searchPaths;

- (NSString*) plugInExtension;
- (void) setPlugInExtension:(NSString*)anExtension;

- (bool) loadPlugInWithIdentifier:(NSString*)identifier error:(NSError**)anError;
- (bool) loadAllPluginsError:(NSError**)anError;

- (NSDictionary*) plugInInformations;
- (PlugInRegistry*) registry;

@end
