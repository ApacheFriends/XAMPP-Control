//
//  PlugInRegistry.m
//  XAMPP Control
//
//  Created by Christian Speich on 20.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlugInRegistry.h"

#define CategorieAssert(categorie) NSParameterAssert((categorie) != Nil && [(categorie) rangeOfString:@"."].location == NSNotFound)

@implementation PlugInRegistry

- (id) init
{
	self = [super init];
	if (self != nil) {
		plugInCategories = [NSMutableDictionary new];
	}
	return self;
}

- (void) dealloc
{
	[plugInCategories release];
	
	[super dealloc];
}

- (void) addCategorie:(NSString*)anCategorie
{
	CategorieAssert(anCategorie);

	// We have already this Categorie in our Registry
	if ([plugInCategories valueForKey:anCategorie]) {
		NSLog(@"%@ already in this Registry.");
		return;
	}
	
	[plugInCategories setValue:[NSArray array] forKey:anCategorie];
}

- (NSArray*) allCategories
{
	return [plugInCategories allKeys];
}

- (NSDictionary*) plugInCategories
{
	return plugInCategories;
}

- (BOOL) registerPlugInWithInfo:(NSDictionary*)anDictionary
{
	NSParameterAssert(anDictionary != Nil);
	
	NSString *categorie;
	NSEnumerator *categorieEnumerator;
		
	// Check if we've all these categories, add missing
	categorieEnumerator = [anDictionary keyEnumerator];
	
	while ((categorie = [categorieEnumerator nextObject])) {
		CategorieAssert(categorie);
		if ([plugInCategories valueForKey:categorie] == Nil) {
			[self addCategorie:categorie];
		}
	}
	
	// Now add the objects from each categorie from plugin
	categorieEnumerator = [anDictionary keyEnumerator];
	
	while ((categorie = [categorieEnumerator nextObject])) {		
		[[plugInCategories mutableArrayValueForKey:categorie] 
		 addObjectsFromArray:[anDictionary valueForKey:categorie]];
	}
	
	return YES;
}

- (NSArray*) objectsForCategorie:(NSString*)anCategorie
{
	CategorieAssert(anCategorie);
	
	NSArray *categorie = [plugInCategories valueForKey:anCategorie];
	
	if (!categorie) {
		[NSException raise:@"Unknown PlugIn Category" 
					format:@"Categorie %@ is not in this Registry!", anCategorie];
		return Nil;
	}
	
	return categorie;
}

- (void) addObject:(id)anObject toCategorie:(NSString*)anCategorie
{
	NSParameterAssert(anObject != Nil);
	CategorieAssert(anCategorie);

	if (![plugInCategories valueForKey:anCategorie]) {
		[NSException raise:@"Unknown PlugIn Category" 
					format:@"Categorie %@ is not in this Registry!", anCategorie];
		return;
	}
	
	[[plugInCategories mutableArrayValueForKey:anCategorie] addObject:anObject];
}

- (void) removeObject:(id)anObject
{
	NSParameterAssert(anObject != Nil);

	NSEnumerator *enumerator = [plugInCategories keyEnumerator];
	NSString *categorie;
	
	while ((categorie = [enumerator nextObject])) {
		[self removeObject:anObject fromCategorie:categorie];
	}
}

- (void) removeObject:(id)anObject fromCategorie:(NSString*)anCategorie
{
	NSParameterAssert(anObject != Nil);
	CategorieAssert(anCategorie);

	if (![plugInCategories valueForKey:anCategorie]) {
		[NSException raise:@"Unknown PlugIn Category" 
					format:@"Categorie %@ is not in this Registry!", anCategorie];
		return;
	}
	
	[[plugInCategories mutableArrayValueForKey:anCategorie] removeObject:anObject];
}

@end

@implementation PlugInRegistry (DEBUG)

- (NSString*) stringFromRegistryContent
{
	return [plugInCategories description];
}

@end

