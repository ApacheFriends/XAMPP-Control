//
//  XPMainThreadProxy.h
//  XAMPP Control
//
//  Created by Christian Speich on 31.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XPMainThreadProxy : NSProxy {
	id				_target;
	NSInvocation*	_invocation;
}

- (id) target;
- (void) setTarget:(id)target;

@end
