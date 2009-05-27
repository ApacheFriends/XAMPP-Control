//
//  SecurityTasksView.m
//  XAMPP Control
//
//  Created by Christian Speich on 17.05.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SecurityTasksView.h"

@interface SecurityTasksView (PRIVAT)

- (void) setupViews;
- (void) recalculateInformations;
- (double) textWidth;
- (NSSize) indicatorSize;
- (NSMutableDictionary*) defaultTaskInformationDict;
- (float) textHeightForString:(NSString*)anString withWidth:(double)width;

- (void) setTaskInformations:(NSArray*)anArray;
- (NSArray*) taskInformations;

@end


@implementation SecurityTasksView

- (void) dealloc
{
	[self setTasks:Nil];
	
	[super dealloc];
}


- (void) setTasks:(NSArray*)anArray
{
	if ([anArray isEqualToArray:tasks])
		return;
	
	[tasks release];
	tasks = [anArray retain];

	[self setTaskInformations:Nil];
	
	[self recalculateInformations];
	
	//[self setupViews];
}

- (NSArray*) tasks
{
	return tasks;
}

- (void) setTaskInformations:(NSArray*)anArray
{
	if ([anArray isEqualToArray:taskInformations])
		return;
	
	[taskInformations release];
	taskInformations = [anArray retain];
}

- (NSArray*) taskInformations
{
	return taskInformations;
}

- (void) recalculateInformations
{
	NSMutableArray* informations;
	int i;
	float yPos = 0;
	float centerOffset = 0.f;
	informations = [NSMutableArray arrayWithCapacity:[[self tasks] count]];
		
	for (i = 0; i < [[self tasks] count]; i++) {
		NSMutableDictionary* dict = [[self taskInformations] objectAtIndex:i];
		NSString* taskString = [[self tasks] objectAtIndex:i];
		float rowHeight = 0;
		NSRect textRect;
		NSRect indicatorRect;

		if (!dict)
			dict = [self defaultTaskInformationDict];
		
		textRect.size.width = [self textWidth];
		textRect.size.height = [self textHeightForString:taskString withWidth:NSWidth(textRect)];
		
		rowHeight = MAX(NSHeight(textRect), [self indicatorSize].height);
		
		indicatorRect.size = [self indicatorSize];
		indicatorRect.origin.x = 0;
		indicatorRect.origin.y = yPos + rowHeight/2.f - NSHeight(indicatorRect)/2.f;
				
		textRect.origin.x = NSMaxX(indicatorRect) + 5.f;
		textRect.origin.y = yPos + rowHeight/2.f - NSHeight(textRect)/2.f;
		
		[dict setObject:NSStringFromRect(indicatorRect) forKey:@"indicatorRect"];
		[dict setObject:NSStringFromRect(textRect) forKey:@"textRect"];
		
		if ([dict objectForKey:@"progressIndicator"] &&
			![[dict objectForKey:@"progressIndicator"] isEqualTo:[NSNull null]])
			[[dict objectForKey:@"progressIndicator"] setFrame:indicatorRect];
		
		[informations addObject:dict];
		NSLog(@"row %f; height %f", yPos, rowHeight);

		yPos += rowHeight + 5.f;
		NSLog(@"row %f", yPos);
	}
	
	/* Ok now everything is calculated center the list verticaly :) 
	
	centerOffset = (NSHeight([self bounds]) - (yPos - 5.f)) / 2.f;
	
	NSLog(@"height: %f content height: %f and centerOffset: %f", NSHeight([self bounds]), yPos -5.f , centerOffset);
	
	if (centerOffset > 0.f) {
		NSMutableDictionary* dict;
		NSEnumerator* enumerator;

		enumerator = [informations objectEnumerator];
		
		while ((dict = [enumerator nextObject])) {
			NSRect textRect;
			NSRect indicatorRect;
			
			textRect = NSRectFromString([dict objectForKey:@"textRect"]);
			indicatorRect = NSRectFromString([dict objectForKey:@"indicatorRect"]);
			
			textRect.origin.y += centerOffset;
			indicatorRect.origin.y += centerOffset;
			
			[dict setObject:NSStringFromRect(indicatorRect) forKey:@"indicatorRect"];
			[dict setObject:NSStringFromRect(textRect) forKey:@"textRect"];
		}
	}*/
	
	[self setTaskInformations:informations];
	
	NSLog(@"informations %@", informations);
}

- (double) textWidth
{
	return NSWidth([self bounds]) - [self indicatorSize].width - /* Space between text and indicator */5.f;
}

- (NSSize) indicatorSize
{
	return NSMakeSize(16.f, 16.f);
}

- (NSMutableDictionary*) defaultTaskInformationDict
{
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:SecurityTaskNoStatus], @"status", 
			NSStringFromRect(NSZeroRect), @"textRect",
			NSStringFromRect(NSZeroRect), @"indicatorRect",
			[NSNull null], @"progressIndicator", Nil];
}

- (float) textHeightForString:(NSString*)anString withWidth:(double)width
{
	NSParameterAssert(anString != Nil);
	NSParameterAssert(width > 0);
		
	NSTextStorage *textStorage;
	NSTextContainer *textContainer;
	NSLayoutManager *layoutManager;
	
	textStorage = [[[NSTextStorage alloc] initWithString:anString] autorelease];
	textContainer = [[[NSTextContainer alloc] initWithContainerSize:NSMakeSize(width, FLT_MAX)] autorelease];
	layoutManager = [[NSLayoutManager new] autorelease];
	
	[layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:layoutManager];
	//[textContainer setLineFragmentPadding:0.0];
	
	[textStorage addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSize]]
						range:NSMakeRange(0, [textStorage length])];
	
	/* Force the layoutmanage to layout the string so we can access the height */
	(void) [layoutManager glyphRangeForTextContainer:textContainer];
	
	//return [layoutManager defaultLineHeightForFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]];

	return NSHeight([layoutManager usedRectForTextContainer:textContainer]);
}

- (void) setupViews
{
	NSEnumerator* enumerator = [taskViews objectEnumerator];
	NSMutableDictionary* dict;
	NSString *task;
	NSProgressIndicator *progressView;
	NSImageView *imageView;
	NSTextField* textField;
	int x = 0;
	int y = 0;
	
	while ((dict = [enumerator nextObject])) {
		[[dict objectForKey:@"textField"] removeFromSuperview];
		[[dict objectForKey:@"progressView"] removeFromSuperview];
		[[dict objectForKey:@"imageView"] removeFromSuperview];
	}
	
	[taskViews release];
	taskViews = [[NSMutableArray alloc] init];
		
	enumerator = [tasks objectEnumerator];
	while ((task = [enumerator nextObject])) {
		NSRect textRect;
		dict = [NSMutableDictionary dictionary];
		
		progressView = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(x, y, 16, 16)];
		imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(x, y, 16, 16)];
		textField = [[NSTextField alloc] init];
		
		[progressView setControlSize:NSSmallControlSize];
		[progressView setStyle:NSProgressIndicatorSpinningStyle];
		[progressView setIndeterminate:YES];
		[progressView setHidden:YES];
		[imageView setHidden:YES];
		[textField setEditable:NO];
		[textField setSelectable:NO];
		[textField setBezeled:NO];
		[textField setDrawsBackground:NO];
		[textField setStringValue:task];
		
		textRect.size = [[textField cell] cellSize];
		textRect.origin.x = 16.f + 5.f;
		textRect.origin.y = y + 16.f/2.f - NSHeight(textRect)/2.f;
		[textField setFrame:textRect];
		
		[self addSubview:progressView];
		[dict setObject:progressView forKey:@"progressView"];
		[self addSubview:imageView];
		[dict setObject:imageView forKey:@"imageView"];
		[self addSubview:textField];
		[dict setObject:textField forKey:@"textField"];
		[dict setObject:[NSNumber numberWithInt:SecurityTaskNoStatus] forKey:@"status"];
		
		[taskViews addObject:dict];
		
		y += 16.f + 9.f;
	}
}

- (SecurityTaskStatus) statusForTask:(uint)task
{
	return [[[taskViews objectAtIndex:task] objectForKey:@"status"] intValue];
}
- (void) setStatus:(SecurityTaskStatus)status forTask:(uint)task
{
	NSMutableDictionary* dict;
	NSImageView* imageView;
	NSProgressIndicator* progressView;
	
	dict = [taskViews objectAtIndex:task];
	
	imageView = [dict objectForKey:@"imageView"];
	progressView = [dict objectForKey:@"progressView"];
	
	[imageView setHidden:YES];
	[progressView setHidden:YES];
	[progressView stopAnimation:self];
	
	switch (status) {
		case SecurityTaskSuccessStatus:
			[imageView setImage:[NSImage imageNamed:@"Success"]];
			[imageView setHidden:NO];
			break;
		case SecurityTaskWorkingStatus:
			[progressView startAnimation:self];
			[progressView setHidden:NO];
			break;
		default:
			break;
	}
}

- (BOOL) isFlipped
{
	return YES;
}

- (void) drawRect:(NSRect)rect
{
	NSEnumerator* informationsEnumerator;
	NSEnumerator* tasksEnumerator;
	NSString* taskString;
	NSDictionary* informationsDict;
	NSTextFieldCell* textCell;
	
	textCell = [NSTextFieldCell new];
	informationsEnumerator = [[self taskInformations] objectEnumerator];
	tasksEnumerator = [[self tasks] objectEnumerator];
	
	while ((taskString = [tasksEnumerator nextObject]) 
		   && (informationsDict = [informationsEnumerator nextObject])) {
		
		[textCell setStringValue:taskString];
		
		[textCell drawWithFrame:NSRectFromString([informationsDict objectForKey:@"textRect"])
						 inView:self];
		
		[[NSColor redColor] set];
		NSRectFill(NSRectFromString([informationsDict objectForKey:@"indicatorRect"]));
	}
}

@end
