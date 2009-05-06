//
//  PlugInRegistry.h
//  XAMPP Control
//
//  Created by Christian Speich on 20.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

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

- (void) invokeHook:(NSString*)hookName withDictionary:(NSDictionary*)dictionary;

@end


@interface PlugInRegistry (DEBUG)

- (NSString*) stringFromRegistryContent;

@end
