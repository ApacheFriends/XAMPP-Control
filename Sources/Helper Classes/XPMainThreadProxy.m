/*
 
 XAMPP
 Copyright (C) 2009 by Apache Friends
 
 Authors of this file:
 - Christian Speich <kleinweby@apachefriends.org>
 
 This file is part of XAMPP.
 
 XAMPP is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 XAMPP is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with XAMPP.  If not, see <http://www.gnu.org/licenses/>.
 
 */

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
