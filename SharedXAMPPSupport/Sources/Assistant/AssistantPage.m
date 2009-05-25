//
//  AssistantPage.m
//  XAMPP Control
//
//  Created by Christian Speich on 24.04.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AssistantPage.h"


@implementation AssistantPage

#pragma mark -
#pragma mark Getter and Setter

- (AssistantPageType) type
{
	return type;
}

- (void) setType:(AssistantPageType)anType
{
	NSParameterAssert(anType > 0 && anType < AssistantUnknownPage);
	
	type = anType;
}

- (NSString*) title
{
	return title;
}

- (void) setTitle:(NSString*)anTitle
{
	NSParameterAssert(anTitle != Nil);
	
	if ([anTitle isEqualToString:title])
		return;
	
	[title release];
	title = [anTitle retain];
}

- (NSString*) stepTitle;
{
	return stepTitle;
}

- (void) setStepTitle:(NSString*)anStepTitle
{
	NSParameterAssert(anStepTitle != Nil);
	
	if ([anStepTitle isEqualToString:stepTitle])
		return;
	
	[stepTitle release];
	stepTitle = [anStepTitle retain];
}

- (AssistantController*) assistantController
{
	return assistantController;
}

- (void) setAssistantController:(AssistantController*)anController
{
	assistantController = anController;
}

#pragma mark -

- (void) pageWillAppear
{ 
}

- (void) pageDidAppear
{
}

- (void) pageWillDisappear
{
}

- (void) pageDidDisappear
{
}

- (BOOL) valid
{
	return YES;
}

@end
