//
//  PlugIn.m
//  XAMPP Control
//
//  Created by Christian Speich on 21.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlugIn.h"


@implementation PlugIn

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self setRegistryInfo:[NSDictionary dictionary]];
	}
	return self;
}


- (BOOL) setupError:(NSError**)anError
{
	if (anError != NULL) {
		*anError = [NSError errorWithDomain:@"" code:1 userInfo:Nil];
	}
	
	return NO;
}

- (void) setRegistryInfo:(NSDictionary*)anDictionary
{
	if ([anDictionary isEqualToDictionary:registryInfo])
		return;
	
	[self willChangeValueForKey:@"registryInfo"];
	
	[registryInfo release];
	registryInfo = [anDictionary retain];
	
	[self didChangeValueForKey:@"registryInfo"];
}

- (NSDictionary*) registryInfo
{
	return registryInfo;
}

@end
