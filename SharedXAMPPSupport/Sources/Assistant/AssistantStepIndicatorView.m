//
//  AssistantStepIndicatorView.m
//  XAMPP Control
//
//  Created by Christian Speich on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AssistantStepIndicatorView.h"

NSString* inactiveStep = @"Inactive";
NSString* disabledStep = @"Disabeld";

@implementation AssistantStepIndicatorView

- (void) dealloc
{
	[steps release];
	[stepInformations release];
	
	[super dealloc];
}


- (NSArray*) steps
{
	return steps;
}

- (void) setSteps:(NSArray*) anArray
{
	[steps release];
	[stepInformations release];
	
	steps = [anArray retain];
	stepInformations = [NSMutableArray new];
	
	for (int i = 0; i < [steps count]; i++)
		[stepInformations addObject:disabledStep];
	
	[self setNeedsDisplay:YES];
}

- (void) selectStep:(uint)step
{
	NSParameterAssert(step < [steps count]);
	
	if (step == currentStepIndex)
		return;
	
	currentStepIndex = step;
	
	for (int i = 0; i <= step; ++i)
		[stepInformations replaceObjectAtIndex:i withObject:inactiveStep];
	
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect {
	NSTextFieldCell* textCell;
	NSImageCell* indicatorCell;
    uint i, count = [steps count];
	NSImage* indicatorImage;
	
	int x = 5;
	int y = 0;
	
	textCell = [NSTextFieldCell new];
	indicatorCell = [NSImageCell new];
	
	[indicatorCell setImageAlignment:NSImageAlignCenter];
	
	for (i = 0; i < count; i++) {
		NSString* step = [steps objectAtIndex:i];
		NSString* stepInformation = [stepInformations objectAtIndex:i];
		NSRect indicatorRect;
		NSRect textRect;
		
		[textCell setStringValue:step];
		
		// First draw the indicator image
		if (i ==  currentStepIndex) {
			indicatorImage = [NSImage imageNamed:@"AssistantStepActive.tiff"];
			[textCell setFont:[NSFont boldSystemFontOfSize:12.f]];
			[textCell setTextColor:[NSColor controlTextColor]];
		} else if ([stepInformation isEqualToString:inactiveStep]) {
			indicatorImage = [NSImage imageNamed:@"AssistantStepInactive.tiff"];
			[textCell setFont:[NSFont systemFontOfSize:12.f]];
			[textCell setTextColor:[NSColor controlTextColor]];
		} else {
			indicatorImage = [NSImage imageNamed:@"AssistantStepDisabled.tiff"];
			[textCell setFont:[NSFont systemFontOfSize:12.f]];
			[textCell setTextColor:[NSColor disabledControlTextColor]];
		}
		
		[indicatorCell setImage:indicatorImage];
		
		
		indicatorRect.size = [indicatorImage size];
		indicatorRect.origin.x = x;
		
		textRect.size = [textCell cellSize];
		textRect.origin.x = NSMaxX(indicatorRect) + 5;
		textRect.origin.y = y;
		y += 19.f;
		
		indicatorRect.origin.y = textRect.origin.y + NSHeight(textRect)/2 - NSHeight(indicatorRect)/2 + 1;
				
		[indicatorCell drawWithFrame:indicatorRect 
							  inView:self];
		
		[textCell drawWithFrame:textRect 
						 inView:self];
	}
	
	[textCell release];
	[indicatorCell release];
}

- (BOOL) isFlipped
{
	return YES;
}

@end
