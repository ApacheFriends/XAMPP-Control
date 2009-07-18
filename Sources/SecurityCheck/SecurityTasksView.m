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
	[self setTaskTitels:Nil];
	
	[super dealloc];
}


- (void) setTaskTitels:(NSArray*)anArray
{
	if ([anArray isEqualToArray:taskTitels])
		return;
	
	[taskTitels release];
	taskTitels = [anArray retain];

	[self setTaskInformations:Nil];
	
	[self recalculateInformations];
}

- (NSArray*) taskTitels
{
	return taskTitels;
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
	informations = [NSMutableArray arrayWithCapacity:[[self taskTitels] count]];
		
	for (i = 0; i < [[self taskTitels] count]; i++) {
		NSMutableDictionary* dict = [[self taskInformations] objectAtIndex:i];
		NSString* taskString = [[self taskTitels] objectAtIndex:i];
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
		DLog(@"row %f; height %f", yPos, rowHeight);

		yPos += rowHeight + 5.f;
		DLog(@"row %f", yPos);
	}
	
	/* Ok now everything is calculated center the list verticaly :)
	
	centerOffset = (NSHeight([self bounds]) - (yPos - 5.f)) / 2.f;
	
	DLog(@"height: %f content height: %f and centerOffset: %f", NSHeight([self bounds]), yPos -5.f , centerOffset);
	
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
	}/**/
	
	[self setTaskInformations:informations];
	
	DLog(@"informations %@", informations);
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
	
	return NSHeight([layoutManager usedRectForTextContainer:textContainer]);
}

- (SecurityTaskStatus) statusForTask:(uint)task
{
	return [[[[self taskInformations] objectAtIndex:task] objectForKey:@"status"] intValue];
}

- (void) setStatus:(SecurityTaskStatus)status forTask:(uint)task
{
	NSMutableDictionary* informationsDict;
	NSProgressIndicator* progressIndicator;
	
	informationsDict = [[[self taskInformations] objectAtIndex:task] mutableCopy];
	
	if ([[informationsDict valueForKey:@"status"] intValue] == status)
		return;
	
	progressIndicator = [informationsDict valueForKey:@"progressIndicator"];
	if (![progressIndicator isEqualTo:[NSNull null]]) {
		[progressIndicator stopAnimation:self];
		[progressIndicator removeFromSuperview];
		[informationsDict setValue:[NSNull null] forKey:@"progressIndicator"];
	}
	
	[informationsDict setValue:[NSNumber numberWithInt:status] forKey:@"status"];
	
	switch (status) {
		case SecurityTaskWorkingStatus:
			progressIndicator = [[NSProgressIndicator alloc] initWithFrame:
								 NSRectFromString([informationsDict objectForKey:@"indicatorRect"])];
			[progressIndicator setControlSize:NSSmallControlSize];
			[progressIndicator setStyle:NSProgressIndicatorSpinningStyle];
			[progressIndicator setIndeterminate:YES];
			[progressIndicator startAnimation:self];
			[self addSubview:progressIndicator];
			[informationsDict setValue:progressIndicator forKey:@"progressIndicator"];
			[progressIndicator release];
			break;
		default:
			break;
	}
	
	[[self mutableArrayValueForKey:@"taskInformations"] replaceObjectAtIndex:task withObject:informationsDict];
	[self setNeedsDisplayInRect:NSRectFromString([informationsDict objectForKey:@"indicatorRect"])];
	[informationsDict release];
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
	NSImageCell* imageCell;
	
	textCell = [NSTextFieldCell new];
	imageCell = [NSImageCell new];
	informationsEnumerator = [[self taskInformations] objectEnumerator];
	tasksEnumerator = [[self taskTitels] objectEnumerator];
	
	while ((taskString = [tasksEnumerator nextObject]) 
		   && (informationsDict = [informationsEnumerator nextObject])) {
		
		[textCell setStringValue:taskString];
		
		switch ([[informationsDict valueForKey:@"status"] intValue]) {
			case SecurityTaskSuccessStatus:
				[imageCell setImage:[NSImage imageNamed:@"TaskSuccess"]];
				break;
			case SecurityTaskFailStatus:
				[imageCell setImage:[NSImage imageNamed:@"TaskFailed"]];
				break;
			default:
				[imageCell setImage:Nil];
				break;
		}
		
		[textCell drawWithFrame:NSRectFromString([informationsDict objectForKey:@"textRect"])
						 inView:self];
		[imageCell drawWithFrame:NSRectFromString([informationsDict objectForKey:@"indicatorRect"])
						  inView:self];
	}
	
	[imageCell release];
	[textCell release];
}

@end
