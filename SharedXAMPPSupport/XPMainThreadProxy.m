//
//  XPMainThreadProxy.m
//  XAMPP Control
//
//  Created by Christian Speich on 31.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XPMainThreadProxy.h"

@implementation XPMainThreadProxy

- (id) init
{
	return self;
}


- (void) dealloc
{
	[self setTarget:Nil];
	
	[super dealloc];
}


- (id) target
{
	return _target;
}

- (void) setTarget:(id)target
{
	if (target == _target)
		return;
	
	[_target release];
	_target = [target retain];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    return [[self target] methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
	[invocation setTarget:[self target]];
	[invocation retainArguments];
	
	[invocation performSelectorOnMainThread:@selector(invoke)
								 withObject:Nil 
							  waitUntilDone:NO];
}

@end
