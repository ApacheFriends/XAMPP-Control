//
//  AssistantStepIndicatorView.h
//  XAMPP Control
//
//  Created by Christian Speich on 26.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AssistantStepIndicatorView : NSView {
	NSArray*		steps;
	NSMutableArray*	stepInformations;
	uint			currentStepIndex;
}

- (NSArray*) steps;
- (void) setSteps:(NSArray*) anArray;

- (void) selectStep:(uint)step;

@end
