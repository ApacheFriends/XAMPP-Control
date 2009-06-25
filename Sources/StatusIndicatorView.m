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

#import "StatusIndicatorView.h"


@implementation StatusIndicatorView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        progressIndicator = [[NSProgressIndicator alloc] initWithFrame:[self bounds]];
		
		[progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
		[progressIndicator setIndeterminate:YES];
		[progressIndicator setControlSize:NSSmallControlSize];
		
		[progressIndicator setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];

		[self addSubview:progressIndicator];
		
		[self setStatus:UnknownStatus];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	NSImage *image;
	
    if (status == NoStatus || status == WorkingStatus)
		return;
	
	switch (status) {
		case GreenStatus:
			image = [NSImage imageNamed:@"IndicatorGreen"];
			break;
		case YellowStatus:
			image = [NSImage imageNamed:@"IndicatorYellow"];
			break;
		case RedStatus:
			image = [NSImage imageNamed:@"IndicatorRed"];
			break;
		default:
			image = [NSImage imageNamed:@"IndicatorUnknown"];
			break;
	}
	
	NSSize imageSize = [image size];
	NSRect imageRect;
	NSRect sourceRect;
	
	imageRect.size = imageSize;
	imageRect.origin.x = NSWidth([self bounds])/2 - imageSize.width/2;
	imageRect.origin.y = NSHeight([self bounds])/2 - imageSize.height/2;
	
	sourceRect.size = imageSize;
	sourceRect.origin.x = sourceRect.origin.y = 0;
		
	[image drawInRect:imageRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:1.f];
}

- (StatusIndicator) status
{
	return status;
}

- (void) setStatus:(StatusIndicator)anStatus
{
	
	if (anStatus == status)
		return;
		
	status = anStatus;
	
	if (anStatus == WorkingStatus) {
		[progressIndicator startAnimation:self];
		[progressIndicator setHidden:NO];
	}
	else {
		[progressIndicator setHidden:YES];
		[progressIndicator stopAnimation:self];
	}
	
	[self setNeedsDisplay:YES];
}

@end
