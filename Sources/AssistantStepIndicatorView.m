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
    uint i, count = [steps count];
	
	int x = 5;
	int y = 0;
		
	for (i = 0; i < count; i++) {
		NSString* step = [steps objectAtIndex:i];
		NSString* stepInformation = [stepInformations objectAtIndex:i];
		NSImage* indicatorImage;
		NSTextFieldCell *textCell = [[NSTextFieldCell alloc] initTextCell:step];
		NSImageCell *indicatorCell;
		NSRect indicatorRect;
		NSRect textRect;
		
		// First draw the indicator image
		if (i ==  currentStepIndex) {
			indicatorImage = [NSImage imageNamed:@"AssistantStepActive.tiff"];
			[textCell setFont:[NSFont boldSystemFontOfSize:12.f]];
		} else if ([stepInformation isEqualToString:inactiveStep]) {
			indicatorImage = [NSImage imageNamed:@"AssistantStepInactive.tiff"];
			[textCell setFont:[NSFont boldSystemFontOfSize:12.f]];
		} else {
			indicatorImage = [NSImage imageNamed:@"AssistantStepDisabled.tiff"];
			[textCell setTextColor:[NSColor darkGrayColor]];
		}
		
		indicatorCell = [[NSImageCell alloc] initImageCell:indicatorImage];
		[indicatorCell setImageAlignment:NSImageAlignCenter];
		
		
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
		
		[textCell release];
	}
}

- (BOOL) isFlipped
{
	return YES;
}

@end
