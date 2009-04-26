//
//  TestPlugin.m
//  XAMPP Control
//
//  Created by Christian Speich on 22.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TestPlugin.h"


@implementation TestPlugin

- (BOOL) setupError:(NSError**)anError
{
	NSLog(@"Yeah setup");
	
	return YES;
}

@end
