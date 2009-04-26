//
//  XPBox.m
//  XAMPP Control
//
//  Created by Christian Speich on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "XPBox.h"

static BOOL hasFillColorMethods = NO;

@implementation XPBox

+ (void)initialize
{
	if ([super instancesRespondToSelector:@selector(fillColor)]) {
		NSLog(@"NSBox supports fillColor.");
		hasFillColorMethods = YES;
	}
}

- (void)setFillColor:(NSColor *)fillColor
{
	if (hasFillColorMethods)
		return [super setFillColor:fillColor];
}

- (NSColor *)fillColor
{
	if (hasFillColorMethods)
		return [super fillColor];
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
}

@end
