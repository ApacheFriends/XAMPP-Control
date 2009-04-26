//
//  NSObject+Unproxy.m
//  iRelayChat
//
//  Created by Christian Speich on 22.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NSObject+Unproxy.h"


@implementation NSObject (Unproxy)

- (id)unproxy { 
    if([self isKindOfClass:NSClassFromString(@"_NSControllerObjectProxy")]) {
        return [self valueForKey:@"unproxy"];
	} else {
        return self; 
    }
}

@end
