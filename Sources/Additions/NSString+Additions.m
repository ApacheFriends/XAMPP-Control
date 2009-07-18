//
//  NSString+Additions.m
//  XAMPP Control
//
//  Created by Christian Speich on 10.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "NSString+Additions.h"


@implementation NSString (Additions)

- (BOOL) boolValue
{
	if ([self hasPrefix:@"Y"]
		|| [self hasPrefix:@"y"]
		|| [self hasPrefix:@"T"]
		|| [self hasPrefix:@"t"])
		return YES;
	
	return [self intValue]!=0;
}

@end
