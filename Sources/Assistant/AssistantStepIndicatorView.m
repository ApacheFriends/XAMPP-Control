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

#import "AssistantStepIndicatorView.h"

NSString* inactiveStep = @"Inactive";
NSString* disabledStep = @"Disabeld";

@implementation AssistantStepIndicatorView

- (void) awakeFromNib
{
		activeImage = [[NSImage alloc] initWithContentsOfFile:
					   [[NSBundle bundleForClass:[AssistantStepIndicatorView class]] 
						pathForImageResource:@"AssistantStepActive"]];
		inactiveImage = [[NSImage alloc] initWithContentsOfFile:
						 [[NSBundle bundleForClass:[AssistantStepIndicatorView class]] 
						  pathForImageResource:@"AssistantStepInactive"]];
		disabledImage = [[NSImage alloc] initWithContentsOfFile:
						 [[NSBundle bundleForClass:[AssistantStepIndicatorView class]] 
						  pathForImageResource:@"AssistantStepDisabled"]];
}


- (void) dealloc
{
	[activeImage release];
	[inactiveImage release];
	[disabledImage release];
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
			indicatorImage = activeImage;
			[textCell setFont:[NSFont boldSystemFontOfSize:12.f]];
			[textCell setTextColor:[NSColor controlTextColor]];
		} else if ([stepInformation isEqualToString:inactiveStep]) {
			indicatorImage = inactiveImage;
			[textCell setFont:[NSFont systemFontOfSize:12.f]];
			[textCell setTextColor:[NSColor controlTextColor]];
		} else {
			indicatorImage = disabledImage;
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
