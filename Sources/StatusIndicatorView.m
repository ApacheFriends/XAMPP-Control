//
//  StatusIndicatorView.m
//  XAMPP Control
//
//  Created by Christian Speich on 16.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

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
		
		[self setStatus:NoStatus];
		
		NSString *greenImagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IndicatorGreen" ofType:@"tiff"];
		greenImage = [[NSImage alloc] initWithContentsOfFile:greenImagePath];
		
		NSString *yellowImagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IndicatorYellow" ofType:@"tiff"];
		yellowImage = [[NSImage alloc] initWithContentsOfFile:yellowImagePath];
		
		NSString *redImagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IndicatorRed" ofType:@"tiff"];
		redImage = [[NSImage alloc] initWithContentsOfFile:redImagePath];
		
		NSString *unknownImagePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"IndicatorUnknown" ofType:@"tiff"];
		unknownImage = [[NSImage alloc] initWithContentsOfFile:unknownImagePath];
    }
    return self;
}

- (void) dealloc
{
	[progressIndicator release];
	[unknownImage release];
	[redImage release];
	[yellowImage release];
	[greenImage release];
	
	[super dealloc];
}


- (void)drawRect:(NSRect)rect {
	NSImage *image;
	
    if (status == NoStatus || status == WorkingStatus)
		return;
	
	switch (status) {
		case GreenStatus:
			image = greenImage;
			break;
		case YellowStatus:
			image = yellowImage;
			break;
		case RedStatus:
			image = redImage;
			break;
		default:
			image = unknownImage;
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
