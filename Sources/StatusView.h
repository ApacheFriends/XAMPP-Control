/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Cocoa/Cocoa.h>
#import "XPStatus.h"

@interface StatusView : NSView {
	XPStatus	lastStatus;
	XPStatus	status;
	
	float		redStatusAlpha;
	NSString	*redStatusText;
	float		greenStatusAlpha;
	NSString	*greenStatusText;
	float		yellowStatusAlpha;
	NSString	*yellowStatusText;
	
	NSAnimation *currentAnimation;
}

- (void)setStatus:(int)status;
- (void)setStatus:(int)status andStatusText:(NSString*)text;

- (void)drawRedStatusInRect:(NSRect)rect;
- (void)drawGreenStatusInRect:(NSRect)rect;
- (void)drawYellowStatusInRect:(NSRect)rect;

@end
