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

@interface PlugInRegistry : NSObject {
	NSMutableDictionary	*plugInCategories;
	NSMutableDictionary* hooks;
}

- (NSArray*) objectsForCategorie:(NSString*)anCategorie;

- (void) addCategorie:(NSString*)anCategorie;
- (NSArray*) allCategories;
- (NSDictionary*) plugInCategories;

- (BOOL) registerPlugInWithInfo:(NSDictionary*)anDictionary;

// These Methods are typically called from PlugIns
- (void) addObject:(id)anObject toCategorie:(NSString*)anCategorie;
- (void) removeObject:(id)anObject;
- (void) removeObject:(id)anObject fromCategorie:(NSString*)anCategorie;

@end

@interface PlugInRegistry (HOOKS)

- (NSInvocation*) registerTarget:(id)anObject withSelector:(SEL)selector forHook:(NSString*)hookName;
- (void) registerInvocation:(NSInvocation*)invocation forHook:(NSString*)hookName;

- (void) invokeHook:(NSString*)hookName withObject:(id)object;

@end


@interface PlugInRegistry (DEBUG)

- (NSString*) stringFromRegistryContent;

@end
