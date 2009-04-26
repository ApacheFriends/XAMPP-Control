//
//  PlugIn.m
//  XAMPP Control
//
//  Created by Christian Speich on 21.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PlugIn.h"


@implementation PlugIn

- (BOOL) setupError:(NSError**)anError
{
	if (anError != NULL) {
		*anError = [NSError errorWithDomain:@"" code:1 userInfo:Nil];
	}
	
	return NO;
}

- (NSDictionary*) registryInfo
{
	return [NSDictionary dictionary];
}

@end
