/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * XAMPP Control - Controls XAMPP                                    *
 * Copyright (C) 2007-2009  Christian Speich <kleinweby@kleinweby.de>*
 *                                                                   *
 * XAMPP Control comes with ABSOLUTELY NO WARRANTY; This is free     * 
 * software, and you are welcome to redistribute it under certain    *
 * conditions; see COPYING for details.                              *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "StatusView.h"
#import "NSBezierPathAdditions.h"

#define STATUS_1_R 27.f/255.f
#define STATUS_1_G 133.f/255.f
#define STATUS_1_B 58.f/255.f
#define STATUS_2_R 255.f/255.f
#define STATUS_2_G 200.f/255.f
#define STATUS_2_B 24.f/255.f
#define STATUS_0_R 222.f/255.f
#define STATUS_0_G 5.f/255.f
#define STATUS_0_B 24.f/255.f

@implementation StatusView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		status = -1;
		[self setStatus:XPUnknownStatus];
    }
    return self;
}

- (void)setStatus:(int)_status
{
	if (status == _status)
		return;
	
	NSString *text;
	
	switch (_status) {
		case XPNotRunning:
			text = NSLocalizedString(@"Not Running", @"Something does not run");
			break;
		case XPRunning:
			text = NSLocalizedString(@"Running", @"Something does run");
			break;
		case XPStarting:
			text = NSLocalizedString(@"Starting", @"Something does start");
			break;
		case XPStopping:
			text = NSLocalizedString(@"Stopping", @"Something does stop");
			break;
		default:
			text = NSLocalizedString(@"Unknown", @"Can't figure out the status");
			break;
	}
	
	[self setStatus:_status andStatusText:text];
}

- (void)setStatus:(int)_status andStatusText:(NSString*)text
{
	if (status == _status)
		return;
	
	switch (_status) {
		case XPNotRunning:
			redStatusText = [text retain];
			break;
		case XPRunning:
			greenStatusText = [text retain];
			break;
		default:
			yellowStatusText = [text retain];
			break;
	}
	
	lastStatus = status;
	status = _status;
	
	switch (status) {
		case XPNotRunning:
			redStatusAlpha = 1.f;
			yellowStatusAlpha = 0.f;
			greenStatusAlpha = 0.f;
			break;
		case XPRunning:
			redStatusAlpha = 0.f;
			yellowStatusAlpha = 0.f;
			greenStatusAlpha = 1.f;
			break;
		default:
			redStatusAlpha = 0.f;
			yellowStatusAlpha = 1.f;
			greenStatusAlpha = 0.f;
			break;
	}
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)_rect {
	
	NSRect rect = NSMakeRect(2.5f, 2.5f, [self bounds].size.width - 5.f, [self bounds].size.height - 5.f);
	
	[self drawRedStatusInRect: rect];
	[self drawGreenStatusInRect: rect];
	[self drawYellowStatusInRect: rect];
}

- (void)drawRedStatusInRect:(NSRect)rect
{
	if (redStatusAlpha == 0.f)
		return;
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect cornerRadius:(rect.size.height/2.f)];
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	NSDictionary *textDict;
	[[NSColor colorWithCalibratedRed:222.f/255.f green:5.f/255.f blue:24.f/255.f alpha:redStatusAlpha] set];
	
	[path fill];
	[path stroke];
	
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	textDict = [NSDictionary dictionaryWithObjectsAndKeys: 
				[NSFont boldSystemFontOfSize:13.f], NSFontAttributeName, 
				paragraphStyle, NSParagraphStyleAttributeName, 
				[NSColor colorWithDeviceRed:1.f green:1.f blue:1.f alpha:redStatusAlpha], @"NSColor", 
				nil];
	[redStatusText drawInRect:rect withAttributes:textDict];
	
	[paragraphStyle release];
}

- (void)drawGreenStatusInRect:(NSRect)rect
{
	if (greenStatusAlpha == 0.f)
		return;
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect cornerRadius:(rect.size.height/2.f)];
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	NSDictionary *textDict;
	[[NSColor colorWithCalibratedRed:27.f/255.f green:133.f/255.f blue:58.f/255.f alpha:greenStatusAlpha] set];
	
	[path fill];
	[path stroke];
	
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	textDict = [NSDictionary dictionaryWithObjectsAndKeys: 
				[NSFont boldSystemFontOfSize:13.f], NSFontAttributeName, 
				paragraphStyle, NSParagraphStyleAttributeName, 
				[NSColor colorWithDeviceRed:1.f green:1.f blue:1.f alpha:greenStatusAlpha], @"NSColor", 
				nil];
	[greenStatusText drawInRect:rect withAttributes:textDict];
	
	[paragraphStyle release];
}

- (void)drawYellowStatusInRect:(NSRect)rect
{
	if (yellowStatusAlpha == 0.f)
		return;
	
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect cornerRadius:(rect.size.height/2.f)];
	NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
	NSDictionary *textDict;
	[[NSColor colorWithCalibratedRed:255.f/255.f green:200.f/255.f blue:24.f/255.f alpha:yellowStatusAlpha] set];
	
	[path fill];
	[path stroke];
	
	[paragraphStyle setAlignment:NSCenterTextAlignment];
	textDict = [NSDictionary dictionaryWithObjectsAndKeys: 
				[NSFont boldSystemFontOfSize:13.f], NSFontAttributeName, 
				paragraphStyle, NSParagraphStyleAttributeName, 
				[NSColor colorWithDeviceRed:1.f green:1.f blue:1.f alpha:yellowStatusAlpha], @"NSColor", 
				nil];
	[yellowStatusText drawInRect:rect withAttributes:textDict];
	
	[paragraphStyle release];
}

- (BOOL)isFlipped
{
	return YES;
}

@end
