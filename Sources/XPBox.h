//
//  XPBox.h
//  XAMPP Control
//
//  Created by Christian Speich on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XPBox : NSBox {
	NSColor *fillColor;
}

- (void)setFillColor:(NSColor *)fillColor;
- (NSColor *)fillColor;

@end
