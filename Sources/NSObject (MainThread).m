//
//  NSObject (MainThread).m
//  XAMPP Control
//
//  Created by Christian Speich on 31.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSObject (MainThread).h"
#import "XPMainThreadProxy.h"

@implementation NSObject (MainThread)

- (id) mainThreadProxy
{
	XPMainThreadProxy *proxy = [[XPMainThreadProxy alloc] init];
	
	[proxy setTarget:self];
	
	return [proxy autorelease];
}

@end
