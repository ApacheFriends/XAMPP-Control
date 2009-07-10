//
//  NSObject+Additions.m
//  XAMPP Control
//
//  Created by Christian Speich on 10.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSObject+Additions.h"
#import "XPMainThreadProxy.h"

@implementation NSObject_Additions

- (id) mainThreadProxy
{
	XPMainThreadProxy *proxy = [[XPMainThreadProxy alloc] init];
	
	[proxy setTarget:self];
	
	return [proxy autorelease];
}

- (id)unproxy { 
    if([self isKindOfClass:NSClassFromString(@"_NSControllerObjectProxy")]) {
        return [self valueForKey:@"unproxy"];
	} else {
        return self; 
    }
}

@end
